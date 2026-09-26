{...}: {
  flake.nixosModules.explo = {config, ...}: {
    sops.secrets."explo-listenbrainz-user-token" = {
      sopsFile = ../secrets/explo.yaml;
      key = "listenbrainz_user_token";
    };

    sops.secrets."explo-listenbrainz-user-name" = {
      sopsFile = ../secrets/explo.yaml;
      key = "listenbrainz_user_name";
    };

    sops.secrets."explo-jellyfin-api-key" = {
      sopsFile = ../secrets/explo.yaml;
      key = "jellyfin_api_key";
    };

    sops.secrets."explo-jellyfin-user-name" = {
      sopsFile = ../secrets/explo.yaml;
      key = "jellyfin_user_name";
    };

    sops.secrets."explo-jellyfin-library-name" = {
      sopsFile = ../secrets/explo.yaml;
      key = "jellyfin_library_name";
    };

    sops.secrets."explo-ui-username" = {
      sopsFile = ../secrets/explo.yaml;
      key = "ui_username";
    };

    sops.secrets."explo-ui-password" = {
      sopsFile = ../secrets/explo.yaml;
      key = "ui_password";
    };

    sops.templates."explo.env" = {
      mode = "0400";
      content = ''
        LISTENBRAINZ_USER_TOKEN=${config.sops.placeholder."explo-listenbrainz-user-token"}
        LISTENBRAINZ_USER=${config.sops.placeholder."explo-listenbrainz-user-name"}
        API_KEY=${config.sops.placeholder."explo-jellyfin-api-key"}
        SYSTEM_USERNAME=${config.sops.placeholder."explo-jellyfin-user-name"}
        LIBRARY_NAME=${config.sops.placeholder."explo-jellyfin-library-name"}
        UI_USERNAME=${config.sops.placeholder."explo-ui-username"}
        UI_PASSWORD=${config.sops.placeholder."explo-ui-password"}
      '';
    };

    virtualisation.oci-containers = {
      backend = "docker";

      containers.explo = {
        serviceName = "explo";
        image = "ghcr.io/lumepart/explo:latest";
        pull = "missing";

        environment = {
          PUID = "2000";
          PGID = "2000";
          TZ = "America/Toronto";
          WEB_UI = "true";
          WIZARD_COMPLETE = "true";
          WEB_ADDR = ":7288";

          # Keep UI settings and schedules alongside the persistent cache.
          WEB_ENV_PATH = "/opt/explo/config/explo.env";
          WEB_DATA_PATH = "/opt/explo/config";

          DOWNLOAD_DIR = "/storage/music/recommendations";
          USE_SUBDIRECTORY = "true";
          DOWNLOAD_SERVICES = "youtube";

          DISCOVERY_SERVICE = "listenbrainz";
          LISTENBRAINZ_DISCOVERY = "playlist";

          # Import weekly recommendations every Tuesday at 00:15 Toronto time.
          WEEKLY_EXPLORATION_SCHEDULE = "15 0 * * 2";
          WEEKLY_EXPLORATION_FLAGS = "--playlist=weekly-exploration --download-mode=normal --replace-playlist=false --clean-downloads=false";

          EXPLO_SYSTEM = "jellyfin";
          SYSTEM_URL = "https://jellyfin.wijeproject.com";
        };

        environmentFiles = [
          config.sops.templates."explo.env".path
        ];

        volumes = [
          "explo-config:/opt/explo/config"
          "/storage/music/recommendations:/storage/music/recommendations"
        ];

        ports = [
          "127.0.0.1:7288:7288"
        ];

        # The image's startup script changes ownership and drops to PUID/PGID.
        extraOptions = [
          "--init"
          "--security-opt=no-new-privileges:true"
        ];
      };
    };

    systemd.services.explo.unitConfig.RequiresMountsFor = [
      "/storage/music/recommendations"
    ];

    # Pi-hole's existing *.wijeproject.com rule resolves this name to Tars.
    services.traefik.dynamicConfigOptions.http = {
      routers.explo = {
        rule = "Host(`explo.wijeproject.com`)";
        entryPoints = [
          "websecure"
          "websecure-ext"
        ];
        service = "explo";
        tls.certResolver = "cloudflare";
        middlewares = [
          "explo-headers"
        ];
      };

      services.explo.loadBalancer.servers = [
        {
          url = "http://127.0.0.1:7288";
        }
      ];

      middlewares.explo-headers.headers.customResponseHeaders = {
        X-Robots-Tag = "noindex,nofollow,nosnippet,noarchive,noimageindex";
      };
    };
  };
}
