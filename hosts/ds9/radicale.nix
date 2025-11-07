{
  pkgs,
  config,
  lib,
  ...
}:
{
  services.radicale = {
    enable = true;
    settings = {
      server.hosts = [ "[::1]:5232" ];
      auth = {
        type = "http_x_remote_user";
        # remote_ip_source = "X-Remote-Addr";
      };
      storage = {
        filesystem_folder = "/var/lib/radicale/collections";
      };
    };
    rights = {
      root = {
        user = ".+";
        collection = "";
        permissions = "R";
      };
      principal = {
        user = ".+";
        collection = "{user}";
        permissions = "RW";
      };
      calendars = {
        user = ".+";
        collection = "{user}/[^/]+";
        permissions = "rw";
      };

    };
  };
  ragon.persist.extraDirectories = [
    "/var/lib/radicale"
  ];

}
