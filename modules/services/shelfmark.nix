{...}: {
  flake.nixosModules.shelfmark = {lib, ...}: let
    # First create a local admin under Settings > Users, then set this to false.
    # Shelfmark cannot bootstrap an admin with AUTH_METHOD=builtin enabled.
    # Setup is only exposed through the LAN/VPN entry point.
    setupMode = false;
  in {
    virtualisation.oci-containers = {
      backend = "docker";
      containers.shelfmark = {
        serviceName = "shelfmark";
        image = "ghcr.io/calibrain/shelfmark:latest";
        pull = "always";

        environment = {
          PUID = "2000";
          PGID = "2000";
          TZ = "America/Toronto";
          FLASK_HOST = "0.0.0.0";
          FLASK_PORT = "8084";
          CONFIG_DIR = "/config";
          SESSION_COOKIE_SECURE = "true";
          AUTH_METHOD =
            if setupMode
            then "none"
            else "builtin";

          BOOKS_OUTPUT_MODE = "folder";
          INGEST_DIR = "/storage/books-library";
          # BookOrbit supports one book per folder, including multiple formats.
          FILE_ORGANIZATION = "organize";
          TEMPLATE_ORGANIZE = "{Author}/{Title} ({Year})/{Author} - {Title}";
          CALIBRE_WEB_URL = "https://books.wijeproject.com";
        };

        volumes = [
          "shelfmark-config:/config"
          "/storage/books-library:/storage/books-library"
        ];
        ports = ["127.0.0.1:8084:8084"];
        extraOptions = [
          "--init"
          "--security-opt=no-new-privileges:true"
        ];
      };
    };

    systemd.services.shelfmark.unitConfig.RequiresMountsFor = [
      "/storage/books-library"
    ];

    # Pi-hole's wildcard DNS already resolves this hostname to Tars.
    services.traefik.dynamicConfigOptions.http = {
      routers.shelfmark = {
        rule = "Host(`getbooks.wijeproject.com`)";
        entryPoints = ["websecure"] ++ lib.optional (!setupMode) "websecure-ext";
        service = "shelfmark";
        tls.certResolver = "cloudflare";
        middlewares = ["shelfmark-headers"];
      };
      services.shelfmark.loadBalancer.servers = [
        {url = "http://127.0.0.1:8084";}
      ];
      middlewares.shelfmark-headers.headers.customResponseHeaders = {
        X-Robots-Tag = "noindex,nofollow,nosnippet,noarchive,noimageindex";
      };
    };
  };
}
