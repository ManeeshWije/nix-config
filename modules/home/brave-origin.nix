_: {
  flake.homeModules.brave-origin = {inputs, pkgs, ...}: {
    home.packages = [
      inputs.brave-origin-nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}.brave-origin
    ];
  };
}
