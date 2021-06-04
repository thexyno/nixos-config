{ config, lib, stdenv, pkgs, ... }:
let
  cfg = config.ragon.networking.router;
  waninterface = "enpasdf";
  laninterface = "enpasdg";
  prefixSize = 59; # set ipv6 prefix size (Vodafone gives us 59 for some reason)
  domain = "hailsatan.eu";
  lan = {
    internet = true;
    ipv4addr = "10.0.0.1";
    netipv4addr = "10.0.0.0";
    dhcpv4start = "10.0.1.1";
    dhcpv4end = "10.0.255.240";
    ipv4size = 16;
    vlan = 3;
  };
  iot = {
    internet = false;
    ipv4addr = "10.1.0.1";
    netipv4addr = "10.1.0.0";
    dhcpv4start = "10.1.1.1";
    dhcpv4end = "10.1.255.240";
    ipv4size = 16;
    vlan = 1;
  };
  guest = {
    internet = false;
    ipv4addr = "192.168.178.1";
    netipv4addr = "192.168.178.0";
    dhcpv4start = "192.168.178.10";
    dhcpv4end = "192.168.178.240";
    ipv4size = 24;
    vlan = 2;
  };
  nets = [ lan iot guest ];
  interfaceGenerator = obj: {
    "${obj}".ipv4 = {
      addresses = [{
        address = obj.ipv4addr;
        prefixLength = obj.ipv4size;
      }];
      routes = [{
        address = obj.ipv4addr;
        prefixLength = obj.ipv4size;
      }];
    };
  };
  statics = [
    { name = "j.hailsatan.eu"      ; ip = "10.0.0.2"; }
    { name = "h.hailsatan.eu"      ; ip = "10.0.0.2"; }
    { name = "grafana.hailsatan.eu"; ip = "10.0.0.2"; }
  ];
in
{
  options.ragon.networking.router.enable = lib.mkEnableOption "Makes this host a router";
  config = lib.mkIf cfg.enable {
    # https://www.willghatch.net/blog/2020/06/22/nixos-raspberry-pi-4-google-fiber-router/

    # You’d better forward packets if you actually want a router.
    boot.kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
      "net.ipv6.conf.default.forwarding" = 1;
    };

    networking.interfaces = let
      genAllInterfaces = map // (map interfaceGenerator nets);

    in {
      "${waninterface}" = {
        useDHCP = true;
      };
      } // genAllInterfaces;
      networking.dhcpcd = {
        enable = true;
        allowInterfaces = [
          "wan"
          "lan"
        ];
        extraConfig =
          ''
            # The man page says that ipv6rs should be disabled globally when
            # using a prefix delegation.
            noipv6rs

            interface wan
            # On the wan interface, we want to ask for a prefix delegation.
            ipv6rs
            ia_pd 2/::/${prefixSize} lan/0/64

            # We don’t want dhcpcd to give us an address on the internal interface.
            interface lan
            noipv4
          '';
      };

      networking.nat = {
        enable = true;
        externalInterface = waninterface;
        internalInterfaces = [ "lan" "iot" "guest" ];
        internalIPs = [ "${guest.netipv4addr}/${guest.ipv4size}" "${iot.netipv4addr}/${iot.ipv4size}" "${lan.netipv4addr}/${lan.ipv4size}" "127.0.0.1/32" ];
      };

      services.dnsmasq = {
        enable = true;
        extraConfig = 
          let
            gen = obj: ''
              dhcp-range=${obj},${obj.dhcpv4start},${obj.dhcpv4end},12h
            '';
            genall = builtins.concatStringsSep "\n" (map gen nets);
            genstatics = builtins.concatStringsSep "\n" (map (a: "address=/${a.name}/${a.ip}") statics);
            netbootxyz = builtins.fetchurl {
              url = "https://boot.netboot.xyz/ipxe/netboot.xyz.efi";
              sha256 = "06lmq4l97pxwg6pp93qmrlgi0ajhjz8xn70833m03lxih00mnxxa";
            };
            netbootxyzpath = stdenv.runCommand "netbootpath" {} ''
              mkdir $out
              ln -s ${netbootxyz} $out/netbootxyz.efi
            '';
          in
          ''
          # https://hveem.no/using-dnsmasq-for-dhcpv6

          # don't ever listen to anything on wan and stuff
          except-interface=${waninterface},${laninterface}

          # don't send bogus requests out on the internets
          bogus-priv
          
          # enable IPv6 Route Advertisements
          enable-ra
          
          # Construct a valid IPv6 range from reading the address set on the interface. The :: part refers to the ifid in dhcp6c.conf. Make sure you get this right or dnsmasq will get confused.
          dhcp-range=tag:${waninterface},::,constructor:${waninterface}, ra-names, 12h

          # ra-names enables a mode which gives DNS names to dual-stack hosts which do SLAAC  for  IPv6.
          # Add your local-only LAN domain
          local=/${domain}/

          #  have your simple hosts expanded to domain
          expand-hosts
          
          # set your domain for expand-hosts
          domain=${domain}

          ${genall}
          ${genstatics}

          dhcp-boot=netbootxyz.efi

          enable-tftp
          tftp-root=${netbootxyzpath}

          # set authoritative mode
          dhcp-authoritative
        '';

      };


    };
  }
