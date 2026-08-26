{inputs, ...}: let
  overlays = [
    inputs.nix-minecraft.overlay

    (final: _prev: {
      unstable = import inputs.nixpkgs-unstable {
        inherit (final.stdenv.hostPlatform) system;

        config.allowUnfree = true;
      };
    })
  ];
in {
  # Make the same overlays available to hosts.nix.
  _module.args.hostOverlays = overlays;

  # pkgs used by flake-parts perSystem modules.
  perSystem = {
    system,
    ...
  }: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;

      config.allowUnfree = true;

      inherit overlays;
    };
  };
}
