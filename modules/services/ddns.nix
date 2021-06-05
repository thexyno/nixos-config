{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.services.ddns;
  domain = config.ragon.services.nginx.domain;
  dataDir = "/var/lib/inadyn";
  cacheDir = "/var/cache/inadyn";
  checkipv6 = pkgs.writeScript "checkipv6.sh" ''
    #!${pkgs.bash}/bin/bash
    ip address show scope global | grep inet6 | awk '{print substr($$2, 1, length($$2)-3)}' | head -n 1
  '';
in
{
  options.ragon.services.ddns.enable = lib.mkEnableOption "Enables CloudFlare DDNS to the domain specified in ragon.services.nginx.domain and all subdomains";
  config = lib.mkIf cfg.enable {
    systemd.services.inadyn = {
      description = "inadyn DDNS Client";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = rec {
        Type = "simple";
        ExecStart = pkgs.writeScript "run-inadyn.sh" ''
          #!${pkgs.bash}/bin/bash
          source /run/secrets/cloudflareAcme
          cat >/run/${RuntimeDirectory}/inadyn.cfg <<EOF
          period = 180
          user-agent = Mozilla/5.0
          provider cloudflare.com {
            username = ${domain}
            password = $CLOUDFLARE_DNS_API_TOKEN
            hostname = ${domain}
          }
          provider cloudflare.com:1 {
            username = ${domain}
            password = $CLOUDFLARE_DNS_API_TOKEN
            hostname = ${domain}
            checkip-command = "${checkipv6}"
          }
          EOF
          exec ${pkgs.inadyn}/bin/inadyn -n --cache-dir=${cacheDir} -f /run/${RuntimeDirectory}/inadyn.cfg
        '';
        RuntimeDirectory = StateDirectory;
        StateDirectory = builtins.baseNameOf dataDir;
      };
    };
    systemd.tmpfiles.rules = [
      "d ${cacheDir} 1777 root root 10m"
    ];
  };
}
