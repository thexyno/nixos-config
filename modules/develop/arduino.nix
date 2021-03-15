{ config, pkgs, ... }:

{
  config.ragon.user.extraGroups = [ "tty" "dialout" ];
  environment.systemPackages = with pkgs; [
    scrcpy
    arduino-cli
    fritzting
    arduino
    esptool
    platformio
  ];
}
