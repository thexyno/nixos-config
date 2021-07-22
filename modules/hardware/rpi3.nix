{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.hardware.rpi3;
in
{
  options.ragon.hardware.rpi3.enable = lib.mkEnableOption "Enables rpi3 quirks";
  config = lib.mkIf cfg.enable {
    # nivea
    services.xserver.videoDrivers = [ "nvidia" ];
  boot.loader.raspberryPi = {
    enable = true;
    version = 3;
  };
  boot.extraModprobeConfig = ''
    options cfg80211 ieee80211_regdom="DE"
  '';
  hardware.firmware = [ pkgs.wireless-regdb ];
  #boot.kernelPackages = pkgs.linux_rpi3;
  nixpkgs.overlays = [
    (self: super: {
      firmwareLinuxNonfree = super.firmwareLinuxNonfree.overrideAttrs (old: {
        version = "2020-12-18";
        src = pkgs.fetchgit {
          url =
            "https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git";
          rev = "b79d2396bc630bfd9b4058459d3e82d7c3428599";
          sha256 = "1rb5b3fzxk5bi6kfqp76q1qszivi0v1kdz1cwj2llp5sd9ns03b5";
        };
        outputHash = "1p7vn2hfwca6w69jhw5zq70w44ji8mdnibm1z959aalax6ndy146";
      });
    })
  ];
  networking.wireless.enable = true;
  hardware.enableRedistributableFirmware = true;
  networking.wireless.interfaces = [ "wlan0" ];

  };
}
