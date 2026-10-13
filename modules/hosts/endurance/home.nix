{inputs, ...}: {
  flake.homeModules.endurance = {
    imports = with inputs.self.homeModules; [
      shell
      firefox
      neovim
      fonts
      umbrielConfig
      noctalia
      ghostty
      tableplus
      lunar-client
    ];
    home.username = "maneesh";
    home.homeDirectory = "/home/maneesh";
    home.stateVersion = "25.11";
  };
}
