{...}: {
  flake.nixosModules.flaresolverr = {...}: {
    services.flaresolverr = {
      enable = true;

      openFirewall = false;

      port = 8191;
    };
  };
}
