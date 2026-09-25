{...}: {
  flake.nixosModules.downtify = {
    virtualisation.oci-containers = {
      backend = "docker";

      containers.downtify = {
        serviceName = "downtify";

        image = "ghcr.io/henriquesebastiao/downtify:latest";
        pull = "missing";

        environment = {
          DOWNTIFY_PORT = "8000";
          DOWNLOAD_DIR = "/storage/music";
          TZ = "America/Toronto";
        };

        volumes = [
          "downtify-data:/data"
          "/storage/music:/storage/music"
        ];

        ports = [
          "127.0.0.1:8000:8000"
        ];

        extraOptions = [
          "--security-opt=no-new-privileges:true"
          "--cap-drop=ALL"
        ];
      };
    };

    # Wait for Gargantua's NFS mount before binding the music library.
    systemd.services.downtify.unitConfig.RequiresMountsFor = [
      "/storage/music"
    ];

    # Pi-hole's existing *.wijeproject.com rule resolves this name to Tars.
    services.traefik.dynamicConfigOptions.http = {
      routers.downtify = {
        rule = "Host(`music.wijeproject.com`)";

        entryPoints = [
          "websecure"
        ];

        service = "downtify";
        tls.certResolver = "cloudflare";

        middlewares = [
          "downtify-headers"
        ];
      };

      services.downtify.loadBalancer.servers = [
        {
          url = "http://127.0.0.1:8000";
        }
      ];

      middlewares.downtify-headers.headers.customResponseHeaders = {
        X-Robots-Tag = "noindex,nofollow,nosnippet,noarchive,noimageindex";
      };
    };
  };
}
