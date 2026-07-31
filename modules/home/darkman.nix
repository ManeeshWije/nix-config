_: {
  flake.homeModules.darkman = {
    pkgs,
    ...
  }: {
    services.darkman = {
      enable = true;

      settings = {
        portal = true;
      };

      darkModeScripts = {
        gtk = ''
          ${pkgs.dconf}/bin/dconf write \
            /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
        '';
      };

      lightModeScripts = {
        gtk = ''
          ${pkgs.dconf}/bin/dconf write \
            /org/gnome/desktop/interface/color-scheme "'prefer-light'"
        '';
      };
    };
  };
}
