{inputs, ...}: {
  flake.homeModules.work-macbook = {
    imports = with inputs.self.homeModules; [
      shell
      neovim
    ];
    home.username = "maneesh";
    home.homeDirectory = "/Users/maneesh";
  };
}
