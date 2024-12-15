{ config, pkgs, lib, ... }: {
   home.packages = [
    # pkgs.dotnet-sdk_8
    pkgs.unstable.dotnet-sdk_9
    pkgs.unstable.jetbrains.rider
    # pkgs.jetbrains.datagrip
    (pkgs.firefox-devedition.overrideAttrs (super: self: { meta.priority = 1; }))
  ];
  
}
