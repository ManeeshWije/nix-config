{...}: {
  flake.homeModules.lunar-client = {pkgs, ...}: {
    home.packages = [
      pkgs.unstable.lunar-client
    ];
  };
}
