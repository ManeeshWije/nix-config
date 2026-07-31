{self, ...}: {
  flake.nixosModules.xdg-portal = {pkgs, ...}: {
    xdg.portal = {
      enable = true;

      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-wlr
      ];

      config = {
        common = {
          default = [
            "gtk"
            "wlr"
          ];
        };
      };

      wlr.settings.screencast = {
        chooser_type = "dmenu";
        chooser_cmd = "${self.packages.${pkgs.stdenv.hostPlatform.system}.noctalia}/bin/noctalia dmenu";
      };
    };
  };
}
