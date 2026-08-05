{ ... }: {
  flake.homeModules.ghostty =
    { pkgs, ... }:
    {
      programs.ghostty = {
        enable = true;

        package =
          if pkgs.stdenv.hostPlatform.isDarwin then
            pkgs.ghostty-bin
          else
            pkgs.ghostty;

        settings = {
          theme = "dark:Black Metal (Gorgoroth),light:Ayu Light";

          font-family = "Iosevka Term Nerd Font";
          font-feature = "-calt, -liga, -dlig";
          font-size = 11;

          mouse-hide-while-typing = true;
          window-decoration = "none";

          cursor-style = "block";
          cursor-style-blink = true;
          cursor-text = "cell-background";
          shell-integration-features = "no-cursor";
        };
      };
    };
}
