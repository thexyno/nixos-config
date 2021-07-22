{ config, inputs, pkgs, lib, ... }:
{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
  ];
  sound.enable = true;
  boot.loader.raspberryPi = {
    enable = true;
    version = 3;
  };
  documentation.enable = false;
  #boot.kernelPackages = pkgs.linux_rpi3;
  boot.extraModprobeConfig = ''
    options cfg80211 ieee80211_regdom="DE"
  '';
  hardware.firmware = [ pkgs.wireless-regdb ];
  documentation.nixos.enable = false;
  networking.interfaces.wlan0.useDHCP = true;
  networking.interfaces.eth0.useDHCP = true;

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
  hardware.pulseaudio.extraConfig = ''
    unload-module module-native-protocol-unix
    load-module module-native-protocol-unix auth-anonymous=1
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
  networking.firewall.enable = false; # danger zone
  hardware.enableRedistributableFirmware = true;
  networking.wireless.interfaces = [ "wlan0" ];

  #nixpkgs.overlays = [
  #  (self: super: {
  #    firmwareLinuxNonfree = super.firmwareLinuxNonfree.overrideAttrs (old: {
  #      version = "2020-12-18";
  #      src = pkgs.fetchgit {
  #        url =
  #          "https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git";
  #        rev = "b79d2396bc630bfd9b4058459d3e82d7c3428599";
  #        sha256 = "1rb5b3fzxk5bi6kfqp76q1qszivi0v1kdz1cwj2llp5sd9ns03b5";
  #      };
  #      outputHash = "1p7vn2hfwca6w69jhw5zq70w44ji8mdnibm1z959aalax6ndy146";
  #    });
  #  })
  #];

}
