{...}: {
  flake.nixosModules.watchtogether = {config, ...}: let
    watchtogetherImage = "maneeshwije/watch-together:latest";
    postgresImage = "postgres:18";
  in {
    #
    # Secrets
    #

    sops.secrets."postgres-password" = {
      sopsFile = ../secrets/watchtogether.yaml;
      key = "postgres-password";
    };

    sops.secrets."aws-access-key-id" = {
      sopsFile = ../secrets/watchtogether.yaml;
      key = "aws-access-key-id";
    };

    sops.secrets."aws-region" = {
      sopsFile = ../secrets/watchtogether.yaml;
      key = "aws-region";
    };

    sops.secrets."aws-s3-bucket" = {
      sopsFile = ../secrets/watchtogether.yaml;
      key = "aws-s3-bucket";
    };

    sops.secrets."aws-secret-access-key" = {
      sopsFile = ../secrets/watchtogether.yaml;
      key = "aws-secret-access-key";
    };

    sops.secrets."aws-url" = {
      sopsFile = ../secrets/watchtogether.yaml;
      key = "aws-url";
    };

    sops.secrets."google-client-id" = {
      sopsFile = ../secrets/watchtogether.yaml;
      key = "google-client-id";
    };

    sops.secrets."google-client-secret" = {
      sopsFile = ../secrets/watchtogether.yaml;
      key = "google-client-secret";
    };

    sops.secrets."yt-cookies-b64" = {
      sopsFile = ../secrets/watchtogether.yaml;
      key = "yt-cookies-b64";
    };
    #
    # Secret environment files
    #
    sops.templates."watchtogether-db.env" = {
      mode = "0400";

      content = ''
        POSTGRES_PASSWORD=${config.sops.placeholder."postgres-password"}
      '';
    };

    sops.templates."watchtogether-app.env" = {
      mode = "0400";

      content = ''
        DATABASE_URL=postgres://watchtogether:${config.sops.placeholder."postgres-password"}@127.0.0.1:5433/watchtogether

        AWS_ACCESS_KEY_ID=${config.sops.placeholder."aws-access-key-id"}
        AWS_SECRET_ACCESS_KEY=${config.sops.placeholder."aws-secret-access-key"}
        AWS_REGION=${config.sops.placeholder."aws-region"}
        AWS_S3_BUCKET=${config.sops.placeholder."aws-s3-bucket"}
        AWS_URL=${config.sops.placeholder."aws-url"}

        GOOGLE_CLIENT_ID=${config.sops.placeholder."google-client-id"}
        GOOGLE_CLIENT_SECRET=${config.sops.placeholder."google-client-secret"}

        YT_COOKIES_B64=${config.sops.placeholder."yt-cookies-b64"}
      '';
    };
    #
    # Docker containers
    #

    virtualisation.oci-containers = {
      backend = "docker";

      containers = {
        watchtogether-db = {
          serviceName = "watchtogether-db";

          image = postgresImage;
          pull = "missing";

          environment = {
            POSTGRES_USER = "watchtogether";
            POSTGRES_DB = "watchtogether";
            PGDATA = "/var/lib/postgresql/data/pgdata";
          };

          environmentFiles = [
            config.sops.templates."watchtogether-db.env".path
          ];

          volumes = [
            "watchtogether-postgres:/var/lib/postgresql/data"
          ];

          ports = [
            "127.0.0.1:5433:5432"
          ];
        };

        watchtogether = {
          serviceName = "watchtogether";

          image = watchtogetherImage;
          pull = "always";

          dependsOn = [
            "watchtogether-db"
            "watchtogether-pot-provider"
          ];

          environment = {
            NODE_ENV = "production";
            MODE = "production";
            PORT = "8080";
            TZ = "America/Toronto";
            BASE_URL = "https://watch.wijeproject.com";
            CLIENT_URL = "https://watch.wijeproject.com";
            YT_POT_PROVIDER_URL = "http://127.0.0.1:4416";
          };

          environmentFiles = [
            config.sops.templates."watchtogether-app.env".path
          ];

          volumes = [
            "watchtogether-app:/data"
          ];

          extraOptions = [
            "--network=host"
            "--init"

            "--security-opt=no-new-privileges:true"
            "--cap-drop=ALL"
          ];
        };

        watchtogether-pot-provider = {
          serviceName = "watchtogether-pot-provider";

          image = "brainicism/bgutil-ytdlp-pot-provider:latest";
          pull = "missing";

          ports = [
            "127.0.0.1:4416:4416"
          ];

          extraOptions = [
            "--init"
            "--security-opt=no-new-privileges:true"
          ];
        };
      };
    };

    #
    # Traefik
    #

    services.traefik.dynamicConfigOptions.http = {
      routers.watchtogether = {
        rule = "Host(`watch.wijeproject.com`)";

        entryPoints = [
          "websecure"
          "websecure-ext"
        ];

        service = "watchtogether";

        tls.certResolver = "cloudflare";

        middlewares = [
          "watchtogether-headers"
        ];
      };

      services.watchtogether.loadBalancer.servers = [
        {
          url = "http://127.0.0.1:8080";
        }
      ];

      middlewares.watchtogether-headers.headers.customResponseHeaders = {
        X-Robots-Tag = "noindex,nofollow,nosnippet,noarchive,noimageindex";
      };
    };
  };
}
