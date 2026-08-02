{inputs, ...}: {
  flake.homeModules.endurance = {
    imports = with inputs.self.homeModules; [
      shell
      firefox
      neovim
      fonts
      niriConfig
      noctalia
      ghostty
      darkTheme
      yaziConfig
    ];
    home.username = "maneesh";
    home.homeDirectory = "/home/maneesh";
  };
}
