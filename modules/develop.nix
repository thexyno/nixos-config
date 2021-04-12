{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.develop;
  otherpkgs = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/a3e9412a4e77841123672976b1cf8f62f348ad51.tar.gz") {};

in
{
  options.ragon.develop.enable = lib.mkEnableOption "Enables ragons development stuff";
  config = lib.mkIf cfg.enable {
    services.lorri.package = otherpkgs.lorri;
    services.lorri.enable = true;
    nixpkgs.config.allowUnfree = true;
    programs.adb.enable = true;
    users.users."${config.ragon.user.username}".extraGroups = [ "adbusers" ];
    services.udev.packages = [
      pkgs.android-udev-rules
    ];
    environment.systemPackages = with pkgs; [
      direnv # needed for lorri
      unixtools.xxd
      nixos-generators
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

