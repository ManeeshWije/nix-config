{inputs, ...}: {
  flake.nixosModules.noctalia-greeter = {pkgs, ...}: {
    imports = [
      inputs.noctalia-greeter.nixosModules.default
    ];
    programs.noctalia-greeter = {
      enable = true;
      package = inputs.noctalia-greeter.packages.${pkgs.stdenv.hostPlatform.system}.default;
    };

    systemd.tmpfiles.rules = let
      greeterConfig = pkgs.writeText "greeter.toml" ''
        [session]
        default = "Niri"

        [appearance]
        scheme = "Ayu"
      '';
    in [
      # L+ = create a symlink, overwriting anything already there, on every boot
      "L+ /var/lib/noctalia-greeter/greeter.toml - - - - ${greeterConfig}"
    ];
  };
}
