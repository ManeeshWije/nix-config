{...}: {
  flake.nixosModules.radarr = {...}: {
    services.radarr = {
      enable = true;
      openFirewall = false;
    };

    #
    # Storage
    #

    # Don't let Radarr start against an unmounted /storage if
    # Gargantua is unavailable.
    systemd.services.radarr.unitConfig.RequiresMountsFor = [
      "/storage/Downloads"
      "/storage/movies"
    ];

    #
    # Traefik
    #

    services.traefik.dynamicConfigOptions.http = {
      routers.radarr = {
        rule = "Host(`radarr.wijeproject.com`)";

        # Internal only.
        entryPoints = [
          "websecure"
        ];

        service = "radarr";

        tls.certResolver = "cloudflare";
      };

      services.radarr.loadBalancer.servers = [
        {
          url = "http://127.0.0.1:7878";
        }
      ];
    };
  };
}
