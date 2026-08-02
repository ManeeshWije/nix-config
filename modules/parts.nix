{inputs, ...}: let
  dfRoot = inputs.dotfiles;
in {
  imports = [
    inputs.home-manager.flakeModules.home-manager
  ];

  systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];

  _module.args = {inherit dfRoot;};

  perSystem = {pkgs, ...}: {
    _module.args = {inherit dfRoot;};
    formatter = pkgs.alejandra;
  };
}
