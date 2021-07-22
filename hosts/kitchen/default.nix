{ config, inputs, pkgs, lib, ... }:
{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
  ];
  boot.loader.raspberryPi = {
    enable = true;
    version = 3;
  };
  documentation.enable = false;
  documentation.nixos.enable = false;

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
  system.autoUpgrade.enable = true;
  system.autoUpgrade.flake = "github:ragon000/nixos-config";
  system.autoUpgrade.allowReboot = true;
  powerManagement.cpuFreqGovernor = "ondemand";

  # Assuming this is installed on top of the disk image.
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  boot.loader.raspberryPi.firmwareConfig = ''
    dtoverlay=hifiberry-dac
  '';
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.systemWide = true;
  hardware.pulseaudio.tcp = {
    enable = true;
    anonymousClients.allowAll = true;
  };
  hardware.pulseaudio.zeroconf.publish.enable = true;

  ragon.user.enable = true;
  ragon.services.ssh.enable = true;
  security.sudo.wheelNeedsPassword = false;
  services.spotifyd.enable = true;
  services.spotifyd.config = ''
    [global]
    backend = "pulseaudio"
    bitrate = 320
    device_name = "Küche"
  '';
  ragon.agenix.enable = false;
  networking.wireless.enable = true;
}
