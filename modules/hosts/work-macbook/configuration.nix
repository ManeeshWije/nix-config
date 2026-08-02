{inputs, ...}: {
  flake.nixosModules.work-macbook = {
    pkgs,
    lib,
    ...
  }: {
    imports = [
      inputs.work-macbook.nixosModules.default
      inputs.self.nixosModules.user
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
