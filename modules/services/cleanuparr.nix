{...}: {
  flake.nixosModules.cleanuparr = {...}: {
    virtualisation.oci-containers = {
      backend = "docker";

      containers.cleanuparr = {
        serviceName = "cleanuparr";
        image = "ghcr.io/cleanuparr/cleanuparr:latest";
        pull = "always";

        environment = {
          PUID = "2000";
          PGID = "2000";
          TZ = "America/Toronto";
          PORT = "11011";
        };

        volumes = [
          "cleanuparr-config:/config"
          "/storage/Downloads:/storage/Downloads"
        ];

        ports = ["127.0.0.1:11011:11011"];

        extraOptions = [
          "--init"
          "--security-opt=no-new-privileges:true"
        ];
      };
    };

    # Wait for Gargantua storage before starting Cleanuparr
    systemd.services.docker-cleanuparr.unitConfig.RequiresMountsFor = [
      "/storage/Downloads"
    ];

    #
    # Traefik (internal only)
    #
    services.traefik.dynamicConfigOptions.http = {
      routers.cleanuparr = {
        rule = "Host(`cleanuparr.wijeproject.com`)";
        entryPoints = ["websecure"];
        service = "cleanuparr";
        tls.certResolver = "cloudflare";
      };

      services.cleanuparr.loadBalancer.servers = [
        {url = "http://127.0.0.1:11011";}
      ];
    };
  };
}
