{pkgs,config,lib,...}:{
  services.ntfy-sh = {
    enable = true;
    settings.base-url = "https://nfty.xyno.systems";
    settings.behind-proxy = true;
    settings.listen-http = ":15992";
  };
  ragon.persist.extraDirectories = [
    "/var/cache/ntfy"
  ];
}
