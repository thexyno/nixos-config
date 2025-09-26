{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
{
  users.users.nginx.isSystemUser = true;
  users.users.nginx.group = "nginx";
  users.groups.nginx = { };
  services.nginx.enable = mkForce false;
  services.nginx.virtualHosts."snipe-it" = mkForce null;
  users.users.caddy.extraGroups = [ config.services.snipe-it.group ];
  ragon.agenix.secrets.ds9SnipeIt = {
    group = config.services.snipe-it.group;
    owner = config.services.snipe-it.user;
    mode = "440";
  };
  services.snipe-it = {
    enable = true;
    database.createLocally = true;
    mail.driver = "sendmail";
    appURL = "https://snipe-it.hailsatan.eu";
    hostName = "snipe-it";
    appKeyFile = config.age.secrets.ds9SnipeIt.path;
    mail.from.address = "root@hailsatan.eu";
  };
  ragon.persist.extraDirectories = [
    config.services.snipe-it.dataDir
  ];

}
