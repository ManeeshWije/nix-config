{...}: {
  flake.nixosModules.jellyfin = {...}: {
    #
    # NFS client
    #
    # NixOS requires NFS support to be explicitly enabled for
    # declarative NFS mounts.
    boot.supportedFilesystems = [
      "nfs"
    ];

    #
    # Gargantua media storage
    #
    fileSystems."/storage" = {
      device = "192.168.88.245:/storage";
      fsType = "nfs4";

      options = [
        "nfsvers=4.2"

        # Jellyfin only needs to read media.
        "ro"

        # This is a network filesystem.
        "_netdev"

        # Don't block Tars boot if Gargantua is unavailable.
        "noauto"
        "x-systemd.automount"
      ];
    };

    #
    # Jellyfin
    #
    services.jellyfin = {
      enable = true;

      # Traefik on Tars will expose Jellyfin.
      # No reason to expose Jellyfin's native ports directly.
      openFirewall = false;
    };

    #
    # Don't let Jellyfin start against an empty /storage directory.
    # Accessing this path also activates the systemd NFS automount.
    #
    systemd.services.jellyfin.unitConfig.RequiresMountsFor = [
      "/storage"
    ];
  };
}
