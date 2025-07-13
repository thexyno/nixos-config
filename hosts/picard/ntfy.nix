{pkgs,config,lib,...}:{
  services.ntfy-sh = {
    enable = true;
    settings.base-url = "https://ntfy.xyno.systems";
    settings.behind-proxy = true;
    settings.listen-http = ":15992";
  };
  ragon.persist.extraDirectories = [
    "/var/cache/ntfy"
  ];
}
