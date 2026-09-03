{...}: {
  flake.nixosModules.seerr = {...}: {
    #
    # Seerr
    #

    services.seerr = {
      enable = true;

      port = 5055;

      openFirewall = false;
    };

    #
    # Traefik
    #

    services.traefik.dynamicConfigOptions.http = {
      routers.seerr = {
        rule = "Host(`discover.wijeproject.com`)";

        entryPoints = [
          "websecure"
          "websecure-ext"
        ];

        service = "seerr";

        tls.certResolver = "cloudflare";

        middlewares = [
          "seerr-headers"
        ];
      };

      services.seerr.loadBalancer.servers = [
        {
          url = "http://127.0.0.1:5055";
        }
      ];

      middlewares.seerr-headers.headers.customResponseHeaders = {
        X-Robots-Tag = "noindex,nofollow,nosnippet,noarchive,noimageindex";
      };
    };
  };
}
