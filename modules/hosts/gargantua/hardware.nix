{pkgs, ...}: {
  flake.nixosModules.gargantua = {
    pkgs,
    lib,
    modulesPath,
    ...
  }: {
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

    boot.initrd.availableKernelModules = [
      "nvme"
      "usbhid"
    ];

    boot.loader.grub.enable = false;
    boot.loader.generic-extlinux-compatible.enable = true;

    hardware.deviceTree = {
      enable = true;

      # Only keep the Pi 5 DTB.
      filter = "bcm2712-rpi-5-b.dtb";

      overlays = [
        {
          name = "pcie-32bit-dma-pi5";
          dtboFile = "${pkgs.raspberrypifw}/share/raspberrypi/boot/overlays/pcie-32bit-dma-pi5.dtbo";
        }
      ];
    };

    boot.initrd.kernelModules = [];
    boot.kernelModules = [];
    boot.extraModulePackages = [];

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/44444444-4444-4444-8888-888888888888";
      fsType = "ext4";
    };

    swapDevices = [];

    nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  };
}
