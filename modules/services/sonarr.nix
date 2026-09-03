{...}: {
  flake.nixosModules.sonarr = {...}: {
    services.sonarr = {
      enable = true;
      openFirewall = false;
    };

    #
    # Storage
    #
    # Do not let Sonarr start against an empty local /storage if Gargantua
    # is unavailable.
    systemd.services.sonarr.unitConfig.RequiresMountsFor = [
      "/storage/Downloads"
      "/storage/shows"
    ];

    #
    # Traefik
    #
    services.traefik.dynamicConfigOptions.http = {
      routers.sonarr = {
        rule = "Host(`sonarr.wijeproject.com`)";

        # Internal only.
        # Do NOT add websecure-ext.
        entryPoints = [
          "websecure"
        ];

        service = "sonarr";

        tls.certResolver = "cloudflare";
      };

      services.sonarr.loadBalancer.servers = [
        {
          url = "http://127.0.0.1:8989";
        }
      ];
    };
  };
}
