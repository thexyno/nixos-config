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
  disableFirewallFor = cfg.disableFirewallFor;
  lan = {
    name = "lan";
    internet = true;
    allowipv6 = true;
    ipv4addr = "10.0.0.1";
    netipv4addr = "10.0.0.0";
    dhcpv4start = "10.0.10.1";
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
        { name = "h.hailsatan.eu"; ip = "10.0.0.1"; }
        { name = "grafana.hailsatan.eu"; ip = "10.0.0.2"; }
      ];
    };
  options.ragon.networking.router.disableFirewallFor =
    lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ # hostnames
        "enterprise"
      ];
    };
  options.ragon.networking.router.staticDHCPs =
    lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [
        { name = "enterprise"; ip = "10.0.0.9"; mac = "d8:cb:8a:76:09:0a"; }
        { name = "ds9"; ip = "10.0.0.2"; mac = "f4:b5:20:0e:21:d5"; }
        { name = "homeassistant"; ip = "10.0.0.20"; mac = "dc:a6:32:f0:43:b8"; }
        { name = "zbbridge"; ip = "10.1.0.5"; mac = "98:f4:ab:e2:b6:a3"; }
        { name = "wled-Schrank-Philipp"; ip = "10.1.0.10"; mac = "2c:f4:32:20:74:60"; }
        { name = "wled-Betthintergrund-Phi"; ip = "10.1.0.11"; mac = "2c:3a:e8:0e:ab:71"; }

        { name = "earthquake"; ip = "10.0.1.2"; mac = "78:24:af:bc:0c:07"; }
        { name = "comet"; ip = "10.0.1.4"; mac = "0c:98:38:d3:16:8f"; }
        { name = "meteor"; ip = "10.0.1.8"; mac = "54:27:1e:5c:1f:ed"; } # Wireless
        { name = "meteor"; ip = "10.0.1.16"; mac = "00:21:cc:5c:f5:dc"; } # Wired
        { name = "hurricane"; ip = "10.0.1.32"; mac = "f0:2f:74:1b:af:e0"; }

        { name = "xbox"; ip = "10.0.2.1"; mac = "58:82:a8:30:2d:1c"; }
        { name = "wii"; ip = "10.0.2.2"; mac = "00:23:cc:50:78:00"; }
        { name = "switch"; ip = "10.0.2.3"; mac = "dc:68:eb:bb:01:fc"; } # Wireless
      ];
    };
  options.ragon.networking.router.forwardedPorts =
    lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [
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
          iaid 0
          ipv6rs
          ia_pd 0/::/${toString prefixSize} lan/0/${toString prefixSize}

          ${allGenIntDescs}
        '';
    };

    networking.firewall.enable = false; # disable iptables cause it's ass to set up
    networking.nftables.enable = true;
    networking.nftables.ruleset =
      let
        unsafeInterfaces = (map (x: x.name) (filter (x: x.internet == false) nets));
        safeInterfaces = (map (x: x.name) (filter (x: x.internet == true) nets)) ++ ["lo"];
        allInternalInterfaces = (map (x: x.name) nets) ++ ["lo"];
        portForwards = concatStringsSep "\n" (map (x: "iifname ${waninterface} ${x.proto} dport ${toString x.sourcePort} dnat ${x.destination}") cfg.forwardedPorts);
        dropUnsafe = concatStringsSep "\n" (map (x: "iifname ${x} drop") unsafeInterfaces);
        allowSafe = concatStringsSep "\n" (map (x: "iifname ${x} accept") safeInterfaces);
        allowSafeOif = concatStringsSep "\n" (map (x: "oifname ${x} ct state { established, related } accept") safeInterfaces);
        allowAll = concatStringsSep "\n" (map (x: "iifname ${x} accept") allInternalInterfaces);
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
            ${allowAll}

            # allow icmp
            ip protocol icmp accept
            ip6 nexthdr icmpv6 accept

            # open port 22, but only allow 2 new connections per minute from each ip
            tcp dport 22 ct state new flow table ssh-ftable { ip saddr limit rate 2/minute } accept
            tcp dport 80 accept
            tcp dport 443 accept
            udp dport 51820 accept

            # everything else
            reject with icmp type port-unreachable
          }
          chain forward {
            type filter hook forward priority 0;

            # allow from loopback and internal nic
            ${allowSafe}

            # allow established/related connections
            ${allowSafeOif}

            # Drop everything else
            drop
          }
          chain output {
            type filter hook output priority 0
            # dont allow any trafic from iot and stuff to escape to the wild
            ${dropUnsafe}
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

          genHosts = obj: ''
            dhcp-host=${obj.mac},${obj.ip},${obj.name}
          '';
          genall = builtins.concatStringsSep "\n" (map gen nets);
          genallHosts = builtins.concatStringsSep "\n" (map genHosts cfg.staticDHCPs);
          genstatics = builtins.concatStringsSep "\n" (map (a: "address=/${a.name}/${a.ip}\naddress=/*.${a.name}/${a.ip}") statics);
          netbootxyz = builtins.fetchurl {
            url = "https://github.com/netbootxyz/netboot.xyz/releases/download/2.0.40/netboot.xyz.efi";
            sha256 = "1gvgvlaxhjkr9i0b2bjq85h12ni9h5fn6r8nphsag3il9kificcc";
          };
          netbootxyzpath = runCommand "netbootpath" { } ''
            mkdir $out
            ln -s ${netbootxyz} $out/netbootxyz.efi
          '';
          disableFirewallForJson = builtins.writeFile (builtins.toJSON disableFirewallFor);
          dispatcher = lib.writeScript "dnsmasq-dispatcher.py" {} ''
            #!${pkgs.python3}/bin/python3
            import json
            import sys
            import subprocess
            if sys.argv[1] is not "del":
              with open("${disableFirewallForJson}","r") as f:
                data = json.load(f)
                if sys.argv[4] in data:
                  subprocess.run(["${pkgs.nftables}/bin/nft", "add", "rule", "inet", "filter", "forward", "ip6", "daddr", sys.argv[3], "accept" ])                  
          '';
        in
        ''
          no-resolv
          server=1.1.1.1
          server=1.0.0.1 # TODO DoH

          # https://hveem.no/using-dnsmasq-for-dhcpv6

          # don't ever listen to anything on wan and stuff
          except-interface=${waninterface},${laninterface}

          listen-address=0.0.0.0,::

          # don't send bogus requests out on the internets
          bogus-priv

          # enable IPv6 Route Advertisements
          enable-ra

          # Construct a valid IPv6 range from reading the address set on the interface. The :: part refers to the ifid in dhcp6c.conf. Make sure you get this right or dnsmasq will get confused.
          dhcp-range=lan,::,constructor:lan, ra-names,slaac, 12h

          # ra-names enables a mode which gives DNS names to dual-stack hosts which do SLAAC  for  IPv6.
          # Add your local-only LAN domain
          local=/${domain}/

          #  have your simple hosts expanded to domain
          expand-hosts

          # set your domain for expand-hosts
          domain=${domain}


          ${genall}
          interface=lo # otherwise localhost dns does not work
          ${genstatics}
          ${genallHosts}

          dhcp-boot=netbootxyz.efi

          addn-hosts=/run/wireguard-hosts

          enable-tftp
          tftp-root=${netbootxyzpath}

          dhcp-script=${dispatcher}

          # set authoritative mode
          dhcp-authoritative

        '';

    };

    services.miniupnpd = {
      # WHY IS SUCH SHIT EVEN NEEDED, STUN SERVERS EXIST, USE THEM *looking at you microsoft*
      enable = false;
      internalIPs = [ lan.name ]; # TODO dynamic with filtered out iot and guest
      natpmp = true; # idk what this is
      externalInterface = waninterface;
    };
  };
}
