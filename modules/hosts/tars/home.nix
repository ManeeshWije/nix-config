{inputs, ...}: {
  flake.homeModules.tars = {
    imports = with inputs.self.homeModules; [
      shell
      neovim
      yaziConfig
    ];
    home.username = "maneesh";
    home.homeDirectory = "/home/maneesh";
    home.stateVersion = "25.11";
  };
}
