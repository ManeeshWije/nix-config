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
      yaziConfig
      tableplus
      lunar-client
    ];
    home.username = "maneesh";
    home.homeDirectory = "/home/maneesh";
    home.stateVersion = "25.11";
  };
}
