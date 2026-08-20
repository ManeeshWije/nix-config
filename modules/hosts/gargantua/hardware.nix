{inputs, ...}: {
  flake.nixosModules.gargantua = {
    lib,
    modulesPath,
    ...
  }: {
    imports = [
      # Build this NixOS configuration as a flashable AArch64 SD image.
      (modulesPath + "/installer/sd-card/sd-image-aarch64.nix")

      # Raspberry Pi 5 kernel + boot/device-tree configuration.
      inputs.nixos-hardware.nixosModules.raspberry-pi-5

      (modulesPath + "/installer/scan/not-detected.nix")
    ];

    # The Pi kernel does not provide tpm-crb, and we already hit this
    # failure when building the Pi kernel previously.
    boot.initrd.systemd.tpm2.enable = false;

    # Penta SATA HAT uses a JMicron JMB585 AHCI controller.
    # The Pi 5 profile already adds nvme, pcie-brcmstb, RP1, etc.
    boot.initrd.availableKernelModules = [
      "ahci"
    ];

    #
    # ZFS
    #
    # Gargantua's SATA array will use ZFS.
    boot.supportedFilesystems = [
      "zfs"
    ];

    # Must stay stable once you have created/imported ZFS pools.
    networking.hostId = "92bd87e4";

    #
    # SD image
    #
    # The stock NixOS image uses a 30 MiB firmware partition.
    # We're intentionally making ours much larger so the Pi firmware,
    # DTBs and overlays actually fit.
    sdImage = {
      firmwareSize = 512;
      expandOnBoot = true;
    };

    image.baseName = "gargantua-rpi5";

    #
    # Raspberry Pi boot firmware
    #
    # The SD-image builder will populate the FAT partition from this
    # configuration instead of using the generic stock population.
    hardware.raspberry-pi.firmware = {
      enable = true;
      uboot.enable = true;
    };

    #
    # Radxa Penta SATA HAT
    #
    hardware.raspberry-pi.configtxt.settings.pi5.dtparam = [
      "pciex1"
      "pciex1_gen=3"
    ];

    hardware.raspberry-pi.configtxt.deviceTreeOverlays.pi5 = [
      {
        "pcie-32bit-dma-pi5" = {};
      }
    ];

    #
    # sd-image.nix defaults this partition to noauto.
    # We want it mounted after installation so future rebuilds can
    # update Pi firmware/config.txt declaratively.
    #
    fileSystems."/boot/firmware".options = lib.mkForce [
      "nofail"
      "fmask=0022"
      "dmask=0022"
    ];

    swapDevices = [];

    nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  };
}
