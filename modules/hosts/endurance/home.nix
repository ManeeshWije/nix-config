{inputs, ...}: {
  flake.homeModules.endurance = {
    imports = with inputs.self.homeModules; [
      shell
      brave-origin
      neovim
      fonts
      niriConfig
      noctalia
      ghostty
      darkTheme
    ];
  };
}
