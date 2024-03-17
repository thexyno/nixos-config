{ config, pkgs, lib, inputs, ... }: {
  ragon.persist.extraDirectories = [ config.services.plex.dataDir ];
  services.plex = {
    enable = true;
    openFirewall = true;
    user = "ragon";
    group = "users";
  };
}