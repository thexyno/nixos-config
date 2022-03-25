{ config, inputs, pkgs, lib, ... }:
{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
    #    "${inputs.nixos-hardware}/raspberry-pi/4/default.nix"
  ];
  boot.supportedFilesystems = lib.mkForce [ "reiserfs" "vfat" "ext4" ]; # we dont need zfs here
  documentation.enable = false;
  documentation.nixos.enable = false;
  boot = {
    kernelPackages = lib.mkDefault pkgs.linuxPackages_rpi4;
    initrd.availableKernelModules = [ "usbhid" "usb_storage" "vc4" ];

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
  ragon.services.agenix.enable = true;
  ragon.hardware.hifiberry-dac.enable = true;
  services.shairport-sync = {
    enable = true;
    arguments = "-o alsa";
  };
}
