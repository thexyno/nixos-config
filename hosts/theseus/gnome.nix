{ pkgs, config, inputs, lib, ... }:
let
  gnomeExtensions = with pkgs.gnomeExtensions; [
    paperwm
    gsconnect
  ];
  gnomeExtensionUuids = map (x: x.extensionUuid) gnomeExtensions;
in
{
  services.xserver.desktopManager.gnome.enable = true;
  environment.systemPackages = gnomeExtensions;
  home-manager.users.ragon.dconf.settings."org/gnome/shell" = {
    "disable-user-extensions" = false;
    enabled-extensions = gnomeExtensionUuids;
  };
}
