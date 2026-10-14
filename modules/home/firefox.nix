{inputs, ...}: {
  flake.homeModules.firefox = {
    lib,
    pkgs,
    ...
  }: let
    firefoxDarwin = pkgs.extend inputs.nixpkgs-firefox-darwin.overlay;
  in {
    home.packages = [
      (
        if pkgs.stdenv.hostPlatform.isDarwin
        then firefoxDarwin.firefox-devedition-bin
        else pkgs.firefox-devedition
      )
    ];

    xdg.desktopEntries = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      firefox-private = {
        name = "Firefox Developer Edition (Private)";
        exec = "firefox-devedition --private-window %U";
        icon = "firefox-devedition";

        categories = ["Network" "WebBrowser"];
        genericName = "Web Browser";
        mimeType = [
          "text/html"
          "text/xml"
          "application/xhtml+xml"
          "application/vnd.mozilla.xul+xml"
          "x-scheme-handler/http"
          "x-scheme-handler/https"
        ];

        startupNotify = true;
        terminal = false;
        type = "Application";
      };
    };
  };
}
