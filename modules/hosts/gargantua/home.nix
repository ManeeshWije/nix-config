{inputs, ...}: {
  flake.homeModules.gargantua = {
    imports = with inputs.self.homeModules; [
      shell
      neovim
    ];
    home.username = "maneesh";
    home.homeDirectory = "/home/maneesh";
    home.stateVersion = "25.11";
  };
}
