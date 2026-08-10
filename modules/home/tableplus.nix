{...}: {
  flake.homeModules.tableplus = {pkgs, ...}: {
    home.packages = [
      pkgs.tableplus
    ];
  };
}
