_: {
  flake.homeModules.darkTheme = {
    pkgs,
    ...
  }: {
    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
    };
  };
}
