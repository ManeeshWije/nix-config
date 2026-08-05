{inputs, ...}: {
  flake.nixosModules.work-macbook = {
    pkgs,
    lib,
    ...
  }: {
    imports = with inputs.self.nixosModules; [
      user
      default
      docker
    ];

    nixpkgs.hostPlatform = lib.mkDefault "aarch64-darwin";

    nix.settings.experimental-features = ["nix-command" "flakes"];

    time.timeZone = "America/Toronto";

    environment.systemPackages = with pkgs; [
    ];

    programs.nix-ld.enable = true;

    system.stateVersion = "25.11";
  };
}
