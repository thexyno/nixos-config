# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, pkgs, modulesPath, ... }:

{
  imports =
    [
      "${modulesPath}/profiles/qemu-guest.nix"
    ];

      fileSystems."/" =
    { device = "/dev/disk/by-uuid/804b4c8e-570d-42a8-aa8f-c5fc3495fe14";
      fsType = "ext4";
    };
  boot.initrd.availableKernelModules = [ "xhci_pci" "uhci_hcd" "virtio_pci" "usbhid" "usb_storage" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/vda";
  networking.useDHCP = true; # lazy
  networking.hostId = "7b45286a";

  users.mutableUsers = false;


  ragon.cli.enable = true;
  ragon.user.enable = true;
  ragon.home-manager.enable = true;
  ragon.gui.enable = true;
  ragon.services.docker.enable = true;
  ragon.services.ssh.enable = true;
  ragon.gui.sway.enable = true;
  ragon.gui.dwm.enable = false;

}
