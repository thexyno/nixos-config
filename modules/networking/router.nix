{ config, lib, pkgs, ... }:
with lib;
with lib.my;
let
  cfg = config.ragon.networking.router;
  waninterface = cfg.waninterface;
  laninterface = cfg.laninterface;
  prefixSize = cfg.prefixSize;
  statics = cfg.statics;
  domain = cfg.domain;
  lan = {
    name = "lan";
    internet = true;
    allowipv6 = true;
    ipv4addr = "10.0.0.1";
    netipv4addr = "10.0.0.0";
    dhcpv4start = "10.0.1.1";
    dhcpv4end = "10.0.255.240";
    ipv4size = 16;
    vlan = 4;
  };
  iot = {
    name = "iot";
    internet = false;
    allowipv6 = false;
    ipv4addr = "10.1.0.1";
    netipv4addr = "10.1.0.0";
    dhcpv4start = "10.1.1.1";
    dhcpv4end = "10.1.255.240";
    ipv4size = 16;
    vlan = 2;
  };
  guest = {
    name = "guest";
    internet = true;
    allowipv6 = false;
    ipv4addr = "192.168.2.1";
    netipv4addr = "192.168.2.0";
    dhcpv4start = "192.168.2.10";
    dhcpv4end = "192.168.2.240";
    ipv4size = 24;
    vlan = 3;
  };
  nets = [ lan iot guest ];
  ipv6nets = builtins.filter (a: a.allowipv6) nets;
  interfaceGenerator = obj: {
    "${obj.name}".ipv4 = {
      addresses = [{
        address = obj.ipv4addr;
        prefixLength = obj.ipv4size;
      }];
      routes = [{
        address = obj.netipv4addr;
        prefixLength = obj.ipv4size;
      }];
    };
  };
in
{
  options.ragon.networking.router.enable = mkBoolOpt false;
  options.ragon.networking.router.waninterface =
    lib.mkOption {
      type = lib.types.str;
      default = "eth1";
    };
  options.ragon.networking.router.laninterface =
    lib.mkOption {
      type = lib.types.str;
      default = "eth0";
    };
  options.ragon.networking.router.domain =
    lib.mkOption {
      type = lib.types.str;
      default = "hailsatan.eu";
    };
  options.ragon.networking.router.prefixSize =
    lib.mkOption {
      type = lib.types.int;
      default = 59;
    };
  options.ragon.networking.router.statics =
    lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [
        { name = "j.hailsatan.eu"; ip = "10.0.0.2"; }
        { name = "nr.hailsatan.eu"; ip = "10.0.0.2"; }
        { name = "h.hailsatan.eu"; ip = "10.0.0.2"; }
        { name = "grafana.hailsatan.eu"; ip = "10.0.0.2"; }
      ];
    };
  options.ragon.networking.router.forwardedPorts =
    lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [
        { sourcePort = 80; destination = "10.0.0.2:80"; proto = "tcp"; }
        { sourcePort = 443; destination = "10.0.0.2:443"; proto = "tcp"; }
      ];
    };
  config = lib.mkIf cfg.enable {
    # https://www.willghatch.net/blog/2020/06/22/nixos-raspberry-pi-4-google-fiber-router/

    # You’d better forward packets if you actually want a router.
    boot.kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
      "net.ipv6.conf.default.forwarding" = 1;
      "net.ipv6.conf.6rdtun.forwarding" = 1;
    };

    networking.vlans =
      let
        genVlan = obj: {
          "${obj.name}" = {
            id = obj.vlan;
            interface = laninterface;
          };
        };
      in
      lib.foldl (a: b: a // b) { } (map genVlan nets);

    networking.interfaces =
      let
        genVlanConf = lib.foldl (a: b: a // b) { } (map interfaceGenerator nets);
      in
      {
        "${waninterface}" = {
          useDHCP = true;
        };
      } // genVlanConf;
    networking.dhcpcd = {
      enable = true;
      allowInterfaces = [
        "${waninterface}"
      ] ++ (map (a: a.name) ipv6nets);
      extraConfig =
        let
          genDesc = obj: ''
            # We don’t want dhcpcd to give us an address on the ${obj.name} interface.
            interface ${obj.name}
            noipv4

          '';
          allGenIntDescs = builtins.concatStringsSep "\n" (map genDesc ipv6nets);
        in
        ''
          # The man page says that ipv6rs should be disabled globally when
          # using a prefix delegation.
          noipv6rs

          interface ${waninterface}
          # On the wan interface, we want to ask for a prefix delegation.
          ipv6rs
          ia_pd 2/::/${toString prefixSize} lan/0/64

          ${allGenIntDescs}
        '';
    };

    networking.firewall.enable = false; # disable iptables cause it's ass to set up
    networking.nftables.enable = true;
    networking.nftables.ruleset =
      let
        unsafeInterfaces = (map (x: x.name) (filter (x: x.internet == false) nets));
        safeInterfaces = (map (x: x.name) (filter (x: x.internet == true) nets));
        allInternalInterfaces = (map (x: x.name) nets);
        portForwards = concatStringsSep "\n" (map (x: "iifname ${waninterface} ${x.proto} dport ${toString x.sourcePort} dnat ${x.destination}") cfg.forwardedPorts);
      in
      ''
        define unsafe_interfaces = {
              ${concatStringsSep ",\n" unsafeInterfaces}
        }
        define safe_interfaces = {
              lo,
              ${concatStringsSep ",\n" safeInterfaces}
        }
        define all_interfaces = {
              lo,
              ${concatStringsSep ",\n" allInternalInterfaces}
        }
        table inet filter {
          chain input {
            type filter hook input priority 0;

            # allow established/related connections
            ct state { established, related } accept

            # early drop of invalid connections
            ct state invalid drop

            # allow from loopback and internal nic
            iifname all_interfaces accept

            # allow icmp
            ip protocol icmp accept
            ip6 nexthdr icmpv6 accept

            # open port 22, but only allow 2 new connections per minute from each ip
            tcp dport 22 ct state new flow table ssh-ftable { ip saddr limit rate 2/minute } accept

            # everything else
            reject with icmp type port-unreachable
          }
          chain forward {
            type filter hook forward priority 0;

            # allow from loopback and internal nic
            iifname safe_interfaces accept

            # allow established/related connections
            oifname safe_interfaces ct state { established, related } accept

            # Drop everything else
            drop
          }
          chain output {
            type filter hook output priority 0
            # dont allow any trafic from iot and stuff to escape to the wild
            iifname unsafe_interfaces drop
          }
        }
        table ip nat {
          chain prerouting {
            type nat hook prerouting priority 0
            ${portForwards}
          }
      
          chain postrouting {
            type nat hook postrouting priority 0
      
            oifname ${waninterface} masquerade
          }
        }
      '';



    # nftables sagt nein
    #
    # networking.nat = {
    #   enable = true;
    #   externalInterface = waninterface;
    #   internalInterfaces = map (a: a.name) nets;
    #   internalIPs = (map (a: "${a.netipv4addr}/${toString a.ipv4size}") nets) ++ [ "127.0.0.1/32" ];
    #   forwardPorts = cfg.forwardedPorts;
    # };

    services.dnsmasq = {
      enable = true;
      alwaysKeepRunning = true;
      extraConfig =
        let
          inherit (pkgs) runCommand;
          gen = obj: ''
            interface=${obj.name}
            dhcp-range=${obj.name},${obj.dhcpv4start},${obj.dhcpv4end},12h
          '';
          genall = builtins.concatStringsSep "\n" (map gen nets);
          genstatics = builtins.concatStringsSep "\n" (map (a: "address=/${a.name}/${a.ip}") statics);
          netbootxyz = builtins.fetchurl {
            url = "https://github.com/netbootxyz/netboot.xyz/releases/download/2.0.40/netboot.xyz.efi";
            sha256 = "1gvgvlaxhjkr9i0b2bjq85h12ni9h5fn6r8nphsag3il9kificcc";
          };
          netbootxyzpath = runCommand "netbootpath" { } ''
            mkdir $out
            ln -s ${netbootxyz} $out/netbootxyz.efi
          '';
        in
        ''
          # https://hveem.no/using-dnsmasq-for-dhcpv6

          # don't ever listen to anything on wan and stuff
          except-interface=${waninterface},${laninterface}

          listen-address=0.0.0.0,::

          # don't send bogus requests out on the internets
          bogus-priv
          
          # enable IPv6 Route Advertisements
          enable-ra
          
          # Construct a valid IPv6 range from reading the address set on the interface. The :: part refers to the ifid in dhcp6c.conf. Make sure you get this right or dnsmasq will get confused.
          dhcp-range=tag:lan,::,constructor:${waninterface}, ra-names,slaac, 12h

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

          addn-hosts=/run/wireguard-hosts

          enable-tftp
          tftp-root=${netbootxyzpath}

          # set authoritative mode
          dhcp-authoritative

          server=1.1.1.1
          server=1.0.0.1 # TODO DoH
        '';

    };

    services.miniupnpd = {
      # WHY IS SUCH SHIT EVEN NEEDED, STUN SERVERS EXIST, USE THEM *looking at you microsoft*
      enable = true;
      internalIPs = [ lan.name ]; # TODO dynamic with filtered out iot and guest
      natpmp = true; # idk what this is
      externalInterface = waninterface;
    };
  };
}
