{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.router;
  externalInterface = cfg.externalInterface;
  internalInterface = cfg.internalInterface;
  dhcpRangeFrom = cfg.dhcpRangeFrom;
  dhcpRangeTo = cfg.dhcpRangeTo;
  subnet = cfg.subnet;
  netMask = cfg.netMask;
  prefixLength = cfg.prefixLength;
  broadcastAddress = cfg.broadcastAddress;
  maxLeaseTime = cfg.maxLeaseTime;
  defaultLeaseTime = cfg.defaultLeaseTime;
  dnsServers = cfg.dnsServers;
  gatewayIP = cfg.gatewayIP;
in
{
  options.ragon.router = {
    enable = lib.mkEnableOption "Enables makes this a router";
    gatewayIP = lib.mkOption {
      type = lib.types.str;
      default = "192.168.2.1";
      description = "the gateway ip";
    };
    externalInterface = lib.mkOption {
      type = lib.types.str;
      default = "wg0";
      description = "the external Interface";
    };
    internalInterface = lib.mkOption {
      type = lib.types.str;
      default = "eth0";
      description = "the internal Interface";
    };
    netMask = lib.mkOption {
      type = lib.types.str;
      default = "255.255.255.0";
      description = "the netmask";
    };
    dhcpRangeFrom = lib.mkOption {
      type = lib.types.str;
      default = "192.168.2.10";
      description = "The Start of the DHCP Range";
    };

    dhcpRangeTo = lib.mkOption {
      type = lib.types.str;
      default = "192.168.2.240";
      description = "The End of the DHCP Range";
    };

    subnet = lib.mkOption {
      type = lib.types.str;
      default = "192.168.2.0";
      description = "The Subnet for NATted clients";
    };

    netmask = lib.mkOption {
      type = lib.types.str;
      default = "255.255.255.0";
      description = "The NetMask for NATted clients";
    };

    prefixLength = lib.mkOption {
      type = lib.types.int;
      default = 24;
      description = "The NetMask for NATted clients";
    };

    broadcastAddress = lib.mkOption {
      type = lib.types.str;
      default = "192.168.2.255";
      description = "The Brotkasten address";
    };

    maxLeaseTime = lib.mkOption {
      type = lib.types.str;
      default = "604800";
      description = "The Maximum DHCP Lease Time";
    };

    defaultLeaseTime = lib.mkOption {
      type = lib.types.str;
      default = "604800";
      description = "The Default DHCP Lease Time";
    };

    dnsServers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "1.1.1.1" "1.0.0.1" ];
      description = "DNS Servers";
    };

  };

  config =
    lib.mkIf cfg.enable {
      networking.nat.enable = true;
      networking.nat.internalIPs = [ "${subnet}/${ toString prefixLength}" ];
      networking.nat.internalInterfaces = [ internalInterface ];
      networking.nat.externalInterface = externalInterface;
      networking.interfaces."${internalInterface}" = {
        ipv4.addresses = [ { address = gatewayIP; prefixLength = prefixLength; } ];
      };

      services.dhcpd4 =
        {
          enable = true;
          interfaces = [ internalInterface ];
          extraConfig = ''
            ddns-update-style none;
            one-lease-per-client true;

            subnet ${subnet} netmask ${netMask} {
              range ${dhcpRangeFrom} ${dhcpRangeTo};
              authoritative;

              # Allows clients to request up to a week (although they won't)
              max-lease-time              ${maxLeaseTime};
              # By default a lease will expire in 24 hours.
              default-lease-time          ${defaultLeaseTime};

              option subnet-mask          ${netMask};
              option broadcast-address    ${broadcastAddress};
              option routers              ${gatewayIP};
              option domain-name-servers  ${(builtins.concatStringsSep ", " dnsServers)};
            }
          '';
        };
    };
}
