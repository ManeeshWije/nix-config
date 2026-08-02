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
      yazi
    ];
    home.username = "maneesh";
    home.homeDirectory = "/home/maneesh";
  };
}
