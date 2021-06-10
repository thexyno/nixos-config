{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.services.nginx;
in
{
  options.ragon.services.nginx.enable = lib.mkEnableOption "Enables nginx";
  options.ragon.services.nginx.domain =
    lib.mkOption {
      type = lib.types.str;
      default = "hailsatan.eu";
    };
  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ 80 443 ];
    services.nginx = {
      enable = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
    };
    security.acme.email = "nixosacme@phochkamp.de";
    security.acme.acceptTerms = true;
    security.acme.certs."${cfg.domain}" = {
      dnsProvider = "cloudflare";
      extraDomainNames = [
        "*.${cfg.domain}"
      ];
      credentialsFile = "/run/secrets/cloudflareAcme";

    };
    ragon.persist.extraDirectories = [
      "/var/lib/acme"
    ];
  };
}
