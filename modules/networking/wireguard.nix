{ config, lib, pkgs, ... }:
with lib;
with lib.my;
with builtins;
let
  hostname = config.networking.hostName;
  wgConfig = genWgConf hostname;
in
{
  config = mkIf wgConfig.enable {
    networking.wg-quick.interfaces."wg0" = traceVal wgConfig.interfaceConfig;
    ragon.agenix.secrets."wireguard${hostname}" = { };

    # A link is used because the file is used in router.nix
    systemd.tmpfiles.rules =
      [
        "L /run/wireguard-hosts - - - - ${pkgs.writeText "wg-hostfile" wgConfig.hostsFile}"
      ];

    networking.firewall.checkReversePath = mkForce false; # mkForce so we still can use mullvad.nix
    services.coredns.enable = (config.ragon.networking.router.enable == false && wgConfig.isServer);
    services.coredns.config = ''
      . {
        bind wg0
        hosts /run/wireguard-hosts
        forward . 1.1.1.1 1.0.0.1
      }
    '';

  };
}
