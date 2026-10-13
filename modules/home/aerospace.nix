_: {
  flake.homeModules.aerospace = {pkgs, ...}: {
    home.packages = [
      pkgs.aerospace
    ];
  };
}
