{inputs, ...}: {
  flake.homeModules.work-macbook = {
    imports = with inputs.self.homeModules; [
      shell
      neovim
      ghostty
      aerospace
      karabiner
      fonts
      firefox
      tableplus
    ];
    home.username = "maneesh";
    home.homeDirectory = "/Users/maneesh";
    home.stateVersion = "25.11";
  };
}
