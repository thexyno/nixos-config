{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.services.ddns;
  domain = config.ragon.services.nginx.domain;
in
{
  options.ragon.services.ddns.enable = lib.mkEnableOption "Enables CloudFlare DDNS to the domain specified in ragon.services.nginx.domain and all subdomains";
  config = lib.mkIf cfg.enable {
    services.cfdyndns = {
      enable = true;
      email = "cloudflare@phochkamp.de";
      records = [
        "${domain}"
        "*.${domain}"
      ];
      apikeyFile = "/run/secrets/cloudflareApiKey";

    };
  };
}
