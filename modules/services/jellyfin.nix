{...}: {
  flake.nixosModules.jellyfin = {...}: {
    #
    # NFS client support
    #
    boot.supportedFilesystems = [
      "nfs"
    ];

    #
    # Gargantua storage
    #
    fileSystems."/storage" = {
      device = "192.168.88.245:/storage";
      fsType = "nfs4";

      options = [
        "nfsvers=4.2"
        "rw"
        "_netdev"

        # Don't make the entire Tars boot depend on Gargantua.
        "noauto"
        "x-systemd.automount"

        # Don't sit forever if Gargantua is unavailable.
        "x-systemd.mount-timeout=10s"
      ];
    };

    #
    # Jellyfin
    #
    services.jellyfin = {
      enable = true;
      openFirewall = false;
    };

    # Ensure Jellyfin doesn't start and scan an empty /storage
    # when Gargantua's NFS filesystem isn't mounted.
    systemd.services.jellyfin.unitConfig.RequiresMountsFor = [
      "/storage"
    ];

    #
    # Traefik
    #
    services.traefik.dynamicConfigOptions.http = {
      routers.jellyfin = {
        rule = "Host(`jellyfin.wijeproject.com`)";

        entryPoints = [
          "websecure"
          "websecure-ext"
        ];

        service = "jellyfin";

        tls = {
          certResolver = "cloudflare";
        };
      };

      services.jellyfin.loadBalancer.servers = [
        {
          url = "http://127.0.0.1:8096";
        }
      ];

      middlewares.jellyfin-headers.headers = {
        customResponseHeaders = {
          X-Robots-Tag = "noindex,nofollow,nosnippet,noarchive,noimageindex";
        };
      };
    };
  };
}
