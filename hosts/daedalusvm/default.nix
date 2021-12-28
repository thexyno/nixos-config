# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ lib, inputs, pkgs, modulesPath, ... }:

{
  imports =
    [
      "${modulesPath}/profiles/qemu-guest.nix"
    ];

      fileSystems."/" =
    { device = "/dev/disk/by-uuid/804b4c8e-570d-42a8-aa8f-c5fc3495fe14";
      fsType = "ext4";
    };
      fileSystems."/boot" =
    { device = "/dev/disk/by-id/boot";
      fsType = "vfat";
    };
  boot.initrd.availableKernelModules = [ "xhci_pci" "uhci_hcd" "virtio_pci" "usbhid" "usb_storage" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];
  networking.hostId = "7b45286a";
  ragon.services.mullvad.enable = lib.mkForce false;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.grub.device = "nodev";


  users.mutableUsers = false;


  ragon.cli.enable = true;
  ragon.user.enable = true;
  ragon.home-manager.enable = true;
  ragon.gui.enable = true;
  ragon.services.docker.enable = true;
  ragon.services.ssh.enable = true;
  #ragon.gui.sway.enable = true;
  #ragon.gui.dwm.enable = false;
  services.xserver.desktopManager.gnome3.enable = true;

}
