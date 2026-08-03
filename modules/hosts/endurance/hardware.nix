{...}: {
  flake.nixosModules.endurance = {
    config,
    lib,
    pkgs,
    modulesPath,
    ...
  }: {
    imports = [(modulesPath + "/installer/scan/not-detected.nix")];

    boot.initrd.availableKernelModules = ["xhci_pci" "nvme" "usb_storage" "sd_mod"];
    boot.initrd.kernelModules = [];
    boot.kernelModules = ["kvm-intel"];
    boot.extraModulePackages = [];

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/0154189f-87d8-49ac-9c74-f7e9d411799d";
      fsType = "ext4";
    };

    swapDevices = [
      {device = "/dev/disk/by-uuid/024b34c4-d369-497c-a2a2-383df8f6bcc6";}
    ];

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
