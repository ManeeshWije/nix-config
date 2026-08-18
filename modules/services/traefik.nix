{...}: {
  flake.nixosModules.traefik = {
    services.traefik = {
      enable = true;

      staticConfigOptions = {
        entryPoints = {
          web.address = ":80";

          # websecure.address = ":443";
        };
      };
    };

    networking.firewall.allowedTCPPorts = [
      80
      # 443
    ];
  };
}
