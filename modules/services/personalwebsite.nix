{...}: {
  flake.nixosModules.personalwebsite = {...}: let
    personalwebsiteImage = "maneeshwije/personal-website:latest";
  in {
    #
    # Docker containers
    #

    virtualisation.oci-containers = {
      backend = "docker";

      containers = {
        personalwebsite = {
          serviceName = "personalwebsite";

          image = personalwebsiteImage;
          pull = "always";

          environment = {
            NODE_ENV = "production";
          };

          extraOptions = [
            "--network=host"
            "--init"

            "--security-opt=no-new-privileges:true"
            "--cap-drop=ALL"
          ];
        };
      };
    };

    #
    # Traefik
    #

    services.traefik.dynamicConfigOptions.http = {
      routers.personalwebsite = {
        rule = "Host(`wijeproject.com`)";

        entryPoints = [
          "websecure"
          "websecure-ext"
        ];

        service = "personalwebsite";

        tls.certResolver = "cloudflare";

        middlewares = [
          "personalwebsite-headers"
        ];
      };

      services.personalwebsite.loadBalancer.servers = [
        {
          url = "http://127.0.0.1:8081";
        }
      ];

      middlewares.personalwebsite-headers.headers.customResponseHeaders = {
        X-Robots-Tag = "noindex,nofollow,nosnippet,noarchive,noimageindex";
      };
    };
  };
}
