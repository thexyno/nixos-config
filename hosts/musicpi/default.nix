{ config, inputs, pkgs, lib, ... }:
{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
    "${inputs.nixpkgs}/nixos/modules/profiles/minimal.nix"
    #    "${inputs.nixos-hardware}/raspberry-pi/4/default.nix"
  ];
  # fix: https://github.com/NixOS/nixpkgs/issues/126755#issuecomment-869149243
  nixpkgs.overlays = [
    (final: super: {
      makeModulesClosure = x:
        super.makeModulesClosure (x // { allowMissing = true; });
    })
  ];
  boot.supportedFilesystems = lib.mkForce [ "reiserfs" "vfat" "ext4" ]; # we dont need zfs here
  boot = {
    kernelPackages = lib.mkDefault pkgs.linuxPackages_rpi4;
    initrd.availableKernelModules = lib.mkForce [
      "ahci"

      "ata_piix"

      "sata_inic162x"
      "sata_nv"
      "sata_promise"
      "sata_qstor"
      "sata_sil"
      "sata_sil24"
      "sata_sis"
      "sata_svw"
      "sata_sx4"
      "sata_uli"
      "sata_via"
      "sata_vsc"

      # USB support, especially for booting from USB CD-ROM
      # drives.
      "uas"

      # SD cards.
      "sdhci_pci"

      "vc4"
      "pcie-brcmstb"
      "simplefb"
      "usbhid"
      "usb_storage"
      "vc4"
    ];

    loader = {
      grub.enable = lib.mkDefault false;
      generic-extlinux-compatible.enable = lib.mkDefault true;
    };
  };

  hardware.deviceTree.filter = "bcm2711-rpi-*.dtb";

  # Required for the Wireless firmware
  hardware.enableRedistributableFirmware = true;

  nix = {
    autoOptimiseStore = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    # Free up to 1GiB whenever there is less than 100MiB left.
    extraOptions = ''
      min-free = ${toString (100 * 1024 * 1024)}
      max-free = ${toString (1024 * 1024 * 1024)}
    '';
  };

  # Assuming this is installed on top of the disk image.
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  ragon.services.ssh.enable = true;
  ragon.agenix.enable = true;
  ragon.hardware.hifiberry-dac.enable = true;
  networking.wireless.enable = true;
  ragon.agenix.secrets.wpa_supplicant = { path = "/etc/wpa_supplicant/wpa_supplicant.conf"; };
  services.shairport-sync = {
    enable = true;
    arguments = "-o alsa";
  };
}
