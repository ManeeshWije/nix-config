_: {
  flake.nixosModules.syncthing = {
    services.syncthing = {
      enable = true;
      user = "maneesh";
      group = "users";

      dataDir = "/home/maneesh/syncthing";
      configDir = "/home/maneesh/.config/syncthing";

      # Opens Syncthing's transfer and discovery ports.
      openDefaultPorts = true;
    };
  };
}
