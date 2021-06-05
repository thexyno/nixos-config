{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.services.ddns;
  domain = config.ragon.services.nginx.domain;
in
{
  options.ragon.services.ddns.enable = lib.mkEnableOption "Enables CloudFlare DDNS to the domain specified in ragon.services.nginx.domain and all subdomains";
  config = lib.mkIf cfg.enable {
    systemd.services.inadyn = {
      description = "inadyn DDNS Client";
      after = [ "network.target" ];
      wantedBy = [ "default.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = pkgs.writeScript "run-inadyn.sh" ''
          #!${pkgs.bash}/bin/bash
          source /run/secrets/cloudflareAcme
          cat > inadyn.cfg <<EOF
          period = 180
          user-agent = Mozilla/5.0
          provider cloudflare.com {
            username = ${domain}
            password = $CLOUDFLARE_DNS_API_TOKEN
            hostname = ${domain}
            ttl = 180
            proxied = false
          }
          EOF
          exec ${pkgs.inadyn}/bin/inadyn -f ./inadyn.cfg
        '';
        WorkingDirectory = "/var/cache/inadyn";
      };
    };
    systemd.tmpfiles.rules = [
      "d /var/cache/inadyn 1777 root root 10m"
    ];
  };
}
