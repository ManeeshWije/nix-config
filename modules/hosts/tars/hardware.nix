{inputs, ...}: {
  flake.nixosModules.tars = {
    lib,
    modulesPath,
    ...
  }: {
    imports = [
      inputs.nixos-hardware.nixosModules.raspberry-pi-5
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

    boot.initrd.availableKernelModules = [
      "nvme"
      "usbhid"
    ];

    boot.initrd.systemd.tpm2.enable = false;

    boot.initrd.kernelModules = [];
    boot.kernelModules = [];
    boot.extraModulePackages = [];

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/44444444-4444-4444-8888-888888888888";
      fsType = "ext4";
    };

fileSystems."/boot" = {
  device = "/dev/disk/by-uuid/2178-694E";
  fsType = "vfat";
};

    fileSystems."/nix" = {
      device = "/dev/disk/by-uuid/554ec9c7-d831-4a7b-b454-99b469be9f50";
      fsType = "ext4";
      neededForBoot = true;
    };

    swapDevices = [];

    nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  };
}
