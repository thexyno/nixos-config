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
    security.acme.defaults.email = "nixosacme@phochkamp.de";
    security.acme.acceptTerms = true;
    security.acme.certs."${cfg.domain}" = {
      dnsProvider = "cloudflare";
      dnsResolver = "1.1.1.1:53";
      group = "nginx";
      extraDomainNames = [
        "*.${cfg.domain}"
      ];
      credentialsFile = "${config.age.secrets.cloudflareAcme.path}";

    };
    services.nginx.virtualHosts."_" = {
      useACMEHost = "${cfg.domain}";
      addSSL = true;
      locations = {
        "/" = {
          extraConfig = ''
            return 404;
          '';
        };
      };
    };

    ragon.agenix.secrets.cloudflareAcme = { group = "nginx"; mode = "0440"; };
    ragon.persist.extraDirectories = [
      "/var/lib/acme"
    ];
  };
}
