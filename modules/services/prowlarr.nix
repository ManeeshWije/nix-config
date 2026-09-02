{...}: {
  flake.nixosModules.prowlarr = {...}: {
    services.prowlarr = {
      enable = true;

      openFirewall = false;

      settings = {
        server = {
          port = 9696;
          bindaddress = "127.0.0.1";
        };

        update = {
          mechanism = "external";
          automatically = false;
        };

        log.analyticsEnabled = false;
      };
    };

    systemd.services.prowlarr = {
      wants = [
        "flaresolverr.service"
      ];

      after = [
        "flaresolverr.service"
      ];
    };

    services.traefik.dynamicConfigOptions.http = {
      routers.prowlarr = {
        rule = "Host(`prowlarr.wijeproject.com`)";

        entryPoints = [
          "websecure"
        ];

        service = "prowlarr";

        tls.certResolver = "cloudflare";
      };

      services.prowlarr.loadBalancer.servers = [
        {
          url = "http://127.0.0.1:9696";
        }
      ];
    };
  };
}
