{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.develop;
in
{
  options.ragon.develop.enable = lib.mkEnableOption "Enables ragons development stuff";
  config = lib.mkIf cfg.enable {
    nixpkgs.config.allowUnfree = true;
    environment.systemPackages = with pkgs; [
      dart
      flutter
      android-studio
      android-udev-rules
      scrcpy
      arduino-cli
      fritzing
      arduino
      esptool
      platformio
    ];
  };
}

