{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.develop;
in
{
  options.ragon.develop.enable = lib.mkEnableOption "Enables ragons development stuff";
  config = lib.mkIf cfg.enable {
    boot.binfmt.emulatedSystems = [ "aarch64-linux" ]; # cross compiling nixos for arm
    programs.adb.enable = true;
    users.users."${config.ragon.user.username}".extraGroups = [ "adbusers" ];
    services.udev.packages = [
      pkgs.android-udev-rules
    ];
    environment.systemPackages = with pkgs; [
      unixtools.xxd
      nixos-generators
      nix-prefetch-scripts
      android-studio
      android-udev-rules
      scrcpy
      arduino-cli
      esptool
      platformio
      jetbrains.idea-ultimate
    ];
    ragon.user.persistent.extraDirectories = [
      ".android"
      "Android"
      ".cache/flutter" # so that flutter get all does not need to ALWAYS be run
      ".pub-cache" # so that flutter get all does not need to ALWAYS be run
      ".npm"
      ".cache/JetBrains"
      ".config/JetBrains"
      ".local/share/JetBrains"
      ".jdks"
      ".java"
      ".m2"
    ];
  };
}
