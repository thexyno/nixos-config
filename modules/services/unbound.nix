{ config, lib, pkgs, ... }:
with builtins; with lib; {
  options.ragon.services.unbound = {
    enable = mkEnableOption "Unbound DNS Resolver";
  };

  config =
  let
    cfg = config.ragon.services.unbound;
  in
  mkIf cfg.enable {
    # Based on https://docs.pi-hole.net/guides/dns/unbound/
    services.unbound = {
      enable = true;
      settings = {
        server = {
          verbosity = "0";
          port = "5353";

          do-ip4 = "yes";
          do-ip6 = "yes";
          do-udp = "yes";
          do-tcp = "yes";
          prefer-ip6 = "yes";

          root-hints = "${config.services.unbound.stateDir}/named.root";

          harden-glue = "yes";
          harden-dnssec-stripped = "yes";
          use-caps-for-id = "no";
          edns-buffer-size = "1472";

          prefetch = "yes";

          num-threads = "1";
          so-rcvbuf = "1m";

          private-address = [
            "192.168.0.0/16"
            "169.254.0.0/16"
            "172.16.0.0/12"
            "10.0.0.0/8"
            "fd00::/8"
            "fe80::/10"
          ];
        };
      };
    };

    # root-hints have to be downloaded without DNS being available
    networking.hosts = {
      "192.0.47.9" = [ "internic.net" "www.internic.net" ];
    };

    systemd.services.unbound.preStart = ''
      set -euo pipefail
      # Update DNSSEC root anchor
      ${pkgs.unbound}/bin/unbound-anchor -a ${config.services.unbound.stateDir}/root.key || echo "Root anchor updated!"
      # Download root hints
      ${pkgs.curl}/bin/curl -fsSL -o ${config.services.unbound.stateDir}/named.root https://www.internic.net/domain/named.root
    '';

    networking.resolvconf.useLocalResolver = false;
  };
}
