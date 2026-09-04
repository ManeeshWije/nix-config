{...}: {
  flake.nixosModules.bookorbit = {
    config,
    pkgs,
    ...
  }: let
    bookorbitImage = "ghcr.io/bookorbit/bookorbit:2.5.0";
    postgresImage = "pgvector/pgvector:pg18";
  in {
    #
    # Secrets
    #

    sops.secrets."bookorbit-postgres-password" = {
      sopsFile = ../secrets/bookorbit.yaml;
      key = "postgres_password";
    };

    sops.secrets."bookorbit-jwt-secret" = {
      sopsFile = ../secrets/bookorbit.yaml;
      key = "jwt_secret";
    };

    sops.secrets."bookorbit-setup-bootstrap-token" = {
      sopsFile = ../secrets/bookorbit.yaml;
      key = "setup_bootstrap_token";
    };

    sops.secrets."bookorbit-request-encryption-key" = {
      sopsFile = ../secrets/bookorbit.yaml;
      key = "request_encryption_key";
    };

    #
    # Secret environment files
    #

    sops.templates."bookorbit-app.env" = {
      mode = "0400";

      content = ''
        POSTGRES_PASSWORD=${config.sops.placeholder."bookorbit-postgres-password"}
        JWT_SECRET=${config.sops.placeholder."bookorbit-jwt-secret"}
        SETUP_BOOTSTRAP_TOKEN=${config.sops.placeholder."bookorbit-setup-bootstrap-token"}
        BOOK_REQUEST_ENCRYPTION_KEY=${config.sops.placeholder."bookorbit-request-encryption-key"}
      '';
    };

    sops.templates."bookorbit-db.env" = {
      mode = "0400";

      content = ''
        POSTGRES_PASSWORD=${config.sops.placeholder."bookorbit-postgres-password"}
      '';
    };

    #
    # Docker containers
    #
    # Docker named volumes are used for application/database state.
    #
    # These survive container recreation and avoid host-side UID/GID
    # problems with PostgreSQL.
    #

    virtualisation.oci-containers = {
      backend = "docker";

      containers = {
        bookorbit-db = {
          serviceName = "bookorbit-db";

          image = postgresImage;
          pull = "missing";

          environment = {
            POSTGRES_USER = "bookorbit";
            POSTGRES_DB = "bookorbit";

            # BookOrbit's current official Compose uses this layout.
            PGDATA = "/var/lib/postgresql/data/pgdata";
          };

          environmentFiles = [
            config.sops.templates."bookorbit-db.env".path
          ];

          volumes = [
            # Docker-managed persistent PostgreSQL data.
            "bookorbit-postgres:/var/lib/postgresql/data"
          ];

          # Database is exposed only on Tars' loopback interface.
          #
          # BookOrbit uses host networking, so it reaches Postgres at
          # 127.0.0.1:5433.
          ports = [
            "127.0.0.1:5433:5432"
          ];
        };

        bookorbit = {
          serviceName = "bookorbit";

          image = bookorbitImage;
          pull = "missing";

          dependsOn = [
            "bookorbit-db"
          ];

          environment = {
            NODE_ENV = "production";
            PORT = "3000";
            TZ = "America/Toronto";

            #
            # PostgreSQL
            #

            POSTGRES_HOST = "127.0.0.1";
            POSTGRES_PORT = "5433";
            POSTGRES_USER = "bookorbit";
            POSTGRES_DB = "bookorbit";

            #
            # Public application URL
            #

            APP_URL = "https://books.wijeproject.com";
            CLIENT_URL = "https://books.wijeproject.com";

            #
            # File permissions
            #
            # Gargantua's NFS export uses all_squash and maps Tars
            # accesses to UID/GID 2000.
            #

            PUID = "2000";
            PGID = "2000";

            BOOKORBIT_FIX_PERMISSIONS = "true";

            #
            # Library
            #
            #   Gargantua: /storage/books
            #   Tars:      /storage/books
            #   BookOrbit: /storage/books
            #

            LIBRARY_BROWSE_ROOT = "/storage/books";

            #
            # Book Dock
            #
            # This is BookOrbit's internal staging directory.
            #
            # It intentionally lives underneath /storage/Downloads so
            # completed qBittorrent downloads and the Book Dock are on
            # the same filesystem. That lets BookOrbit use hardlinks.
            #
            # Nix creates this automatically below.
            #

            BOOK_DOCK_PATH = "/storage/Downloads/.bookorbit-dock";

            #
            # Runtime
            #

            NODE_MAX_OLD_SPACE_SIZE = "2048";
            LOG_LEVEL = "info";
          };

          environmentFiles = [
            config.sops.templates."bookorbit-app.env".path
          ];

          volumes = [
            #
            # Persistent BookOrbit state.
            #
            # Users, application settings, library configuration,
            # requests, download clients, sources, etc. persist here.
            #

            "bookorbit-app:/data"

            #
            #   /storage/Downloads
            #   /storage/Downloads/.bookorbit-dock
            #   /storage/books
            #
            # are all part of the same mount/filesystem.
            #

            "/storage:/storage"
          ];

          extraOptions = [
            "--network=host"

            "--init"

            #
            # Match BookOrbit's official hardened container setup.
            #

            "--read-only"
            "--tmpfs=/tmp"

            "--security-opt=no-new-privileges:true"

            "--cap-drop=ALL"
            "--cap-add=CHOWN"
            "--cap-add=DAC_OVERRIDE"
            "--cap-add=FOWNER"
            "--cap-add=SETGID"
            "--cap-add=SETUID"
          ];
        };
      };
    };

    #
    # BookOrbit startup
    #

    systemd.services.bookorbit = {
      #
      # Make sure Gargantua's NFS filesystem is actually mounted before
      # Docker starts BookOrbit.
      #

      unitConfig.RequiresMountsFor = [
        "/storage"
      ];

      #
      # Automatically create BookOrbit's staging directory.
      #
      # Then wait until PostgreSQL is actually accepting connections
      # before launching BookOrbit.
      #

      preStart = ''
        ${pkgs.coreutils}/bin/mkdir -p \
          /storage/Downloads/.bookorbit-dock

        until ${pkgs.postgresql_18}/bin/pg_isready \
          -h 127.0.0.1 \
          -p 5433 \
          -U bookorbit \
          -d bookorbit
        do
          sleep 1
        done
      '';
    };

    #
    # Traefik
    #

    services.traefik.dynamicConfigOptions.http = {
      routers.bookorbit = {
        rule = "Host(`books.wijeproject.com`)";

        entryPoints = [
          "websecure"
          "websecure-ext"
        ];

        service = "bookorbit";

        tls.certResolver = "cloudflare";

        middlewares = [
          "bookorbit-headers"
        ];
      };

      services.bookorbit.loadBalancer.servers = [
        {
          url = "http://127.0.0.1:3000";
        }
      ];

      middlewares.bookorbit-headers.headers.customResponseHeaders = {
        X-Robots-Tag = "noindex,nofollow,nosnippet,noarchive,noimageindex";
      };
    };
  };
}
