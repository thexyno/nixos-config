{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    dart
    flutter
    android-studio
    android-udev-rules
    scrcpy
  ];


}
