{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.ragon.tailscaleToVpn;
  ovpnConfigPath = cfg.ovpnConfigPath;
  stateVer = config.system.stateVersion;
in
{

  options.ragon.tailscaleToVpn = {
    enable = mkEnableOption "tailscale-to-vpn. you need to enable nat to ve-+ able to use this";
    ovpnConfigPath = mkOption {
      type = types.str;
      default = "/etc/openvpn/client.conf";
      description = "full path to the OpenVPN client configuration file, is expected to be in /run";
    };
  };

  config = mkIf cfg.enable {
    networking.bridges.br-ovpn-ts = {
      interfaces = [ ];
    };
    containers.TSTVPN-openvpn = {
      ephemeral = true;
      enableTun = true;
      interfaces = [ "br-ovpn-ts" ];
      localAddress = "192.168.102.11";
      hostAddress = "192.168.102.10";

      config = { config, pkgs, ... }: {
        system.stateVersion = stateVer;
        networking.interfaces.br-ovpn-ts = {
          ipv4.addresses = [ "192.168.101.1/24" ];
        };
        services.openvpn.servers.bridge = {
          config = ''
            config /host${ovpnConfigPath}
            dev ovpn-bridge
            dev-type tun
          '';
        };
        networking.nat = {
          externalInterface = "ovpn-bridge";
          internalInterfaces = [ "br-ovpn-ts" ];
        };
      };
      privateNetwork = true;
      bindMounts = {
        "/host/run" = { hostPath = "/run"; isReadOnly = true; };
        "/run/agenix.d" = { hostPath = "/run/agenix.d"; isReadOnly = true; };
      };
    };
    containers.TSTVPN-tailscale = {
      enableTun = true;
      hostBridge = "br-ovpn-ts";
      localAddress = "192.168.101.2/24";
      privateNetwork = true;
      config = { config, pkgs, ... }: {
        system.stateVersion = stateVer;
        services.tailscale = {
          enable = true;
          useRoutingFeatures = "both";
        };
      };
    };

  };
}
