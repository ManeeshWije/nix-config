{...}: {
  flake.nixosModules.nfs = {...}: {
    services.nfs.server = {
     enable = true;

      exports = ''
        /storage 192.168.88.251(ro,sync,no_subtree_check)
      '';
    };

    networking.firewall.allowedTCPPorts = [
      2049
    ];
  };
}
