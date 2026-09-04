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
    # Environment files
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
    # Local persistent application state
    #
    # Nix creates these automatically.
    #

    systemd.tmpfiles.rules = [
      "d /var/lib/bookorbit 0755 root root - -"
      "d /var/lib/bookorbit/app 0755 root root - -"
      "d /var/lib/bookorbit/postgres 0700 root root - -"
    ];

    #
    # Containers
    #

    virtualisation.oci-containers.backend = "docker";

    virtualisation.oci-containers.containers = {
      bookorbit-db = {
        serviceName = "bookorbit-db";

        image = postgresImage;
        pull = "missing";

        environment = {
          POSTGRES_USER = "bookorbit";
          POSTGRES_DB = "bookorbit";

          PGDATA = "/var/lib/postgresql/data/pgdata";
        };

        environmentFiles = [
          config.sops.templates."bookorbit-db.env".path
        ];

        volumes = [
          "/var/lib/bookorbit/postgres:/var/lib/postgresql/data"
        ];

        # Only the host / BookOrbit can access Postgres.
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

          POSTGRES_HOST = "127.0.0.1";
          POSTGRES_PORT = "5433";
          POSTGRES_USER = "bookorbit";
          POSTGRES_DB = "bookorbit";

          APP_URL = "https://books.wijeproject.com";
          CLIENT_URL = "https://books.wijeproject.com";

          #
          # Existing library.
          #
          LIBRARY_BROWSE_ROOT = "/storage/books";

          #
          # BookOrbit's staging directory.
          #
          # It lives inside Downloads so hardlinks to completed
          # qBittorrent files work.
          #
          BOOK_DOCK_PATH = "/storage/Downloads/.bookorbit-dock";

          NODE_MAX_OLD_SPACE_SIZE = "2048";

          BOOKORBIT_FIX_PERMISSIONS = "true";
          LOG_LEVEL = "info";
        };

        environmentFiles = [
          config.sops.templates."bookorbit-app.env".path
        ];

        volumes = [
          #
          # Persistent BookOrbit application state.
          #
          "/var/lib/bookorbit/app:/data"

          #
          # Mount /storage once rather than mounting books and
          # Downloads independently. This keeps downloads,
          # Book Dock and the library on one filesystem from
          # BookOrbit's point of view, allowing hardlinks.
          #
          "/storage:/storage"
        ];

        #
        # Host networking is intentional.
        #
        # BookOrbit can then directly access:
        #
        #   Prowlarr:
        #     127.0.0.1:9696
        #
        #   qBittorrent namespace:
        #     10.200.200.2:8080
        #
        networks = [
          "host"
        ];

        extraOptions = [
          "--init"
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

    #
    # BookOrbit startup
    #

    systemd.services.bookorbit = {
      #
      # This causes Tars' existing NFS automount to mount Gargantua
      # before Docker starts BookOrbit.
      #
      unitConfig.RequiresMountsFor = [
        "/storage"
      ];

      # create BookOrbit's required staging area automatically and
      # wait until PostgreSQL is actually ready.
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
