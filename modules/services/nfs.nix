{...}: {
  flake.nixosModules.nfs = {...}: {
    #
    # Storage identity
    #
    # Every NFS request from Tars is mapped to this user.
    # qBittorrent/Sonarr/Jellyfin users on Tars therefore do not need
    # matching UIDs or shared groups.
    #
    users.groups.storage = {
      gid = 2000;
    };

    users.users.storage = {
      isSystemUser = true;
      uid = 2000;
      group = "storage";
    };

    #
    # NFS
    #
    services.nfs.server = {
      enable = true;

      exports = ''
        /storage 192.168.88.251(rw,sync,no_subtree_check,all_squash,anonuid=2000,anongid=2000)
      '';
    };

    networking.firewall.allowedTCPPorts = [
      2049
    ];
  };
}
