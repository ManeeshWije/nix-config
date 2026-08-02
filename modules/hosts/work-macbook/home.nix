{inputs, ...}: {
  flake.homeModules.work-macbook = {
    imports = with inputs.self.homeModules; [
      shell
      neovim
      yaziConfig
    ];
    home.username = "maneesh";
    home.homeDirectory = "/Users/maneesh";
    home.stateVersion = "25.11";
  };
}
