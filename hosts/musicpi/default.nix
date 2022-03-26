{ config, inputs, pkgs, lib, ... }:
{
  imports = [
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
  sound.enable = true;
  boot = {
    extraModprobeConfig = ''
      options cfg80211 ieee80211_regdom="DE"
    '';
    kernelPackages = lib.mkDefault pkgs.linuxPackages_rpi3;
    initrd.availableKernelModules = lib.mkForce [ "md_mod" "ext2" "ext4" "sd_mod" "sr_mod" "mmc_block" "ehci_hcd" "ohci_hcd" "xhci_hcd" "usbhid" "hid_generic" ]; 
    loader = {
      grub.enable = lib.mkDefault false;
      generic-extlinux-compatible.enable = lib.mkForce false;
      raspberryPi.enable = true;
      raspberryPi.version = 3;
      raspberryPi.uboot.enable = false;
      raspberryPi.firmwareConfig = ''
        dtparam=hifiberry-dac
      '';
    };
  };

  # Required for the Wireless firmware
  hardware = {
    firmware = [ pkgs.wireless-regdb pkgs.raspberrypiWirelessFirmware ];
    enableRedistributableFirmware = lib.mkForce false;
  };

  nix = {
    settings.auto-optimise-store = true;
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

  environment.systemPackages = [ pkgs.alsa-utils ];
  ragon.services.ssh.enable = true;
  ragon.agenix.enable = true;
  networking.wireless.enable = true;
  ragon.agenix.secrets.wpa_supplicant = { path = "/etc/wpa_supplicant.conf"; };
  services.shairport-sync = {
    enable = true;
    arguments = "-o alsa -v";
    openFirewall = true;
  };
}
