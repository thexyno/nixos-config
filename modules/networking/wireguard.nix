{ config, lib, pkgs, ... }:
with lib;
with lib.my;
with builtins;
let
  wgConfig = importTOML ../../data/wireguard.toml;
  toLowerHex = id: toLower (toHexString id); # only works for ids 0-65535
  toIpv4 = id: builtins.concatStringsSep "." (map toString (toBaseDigits 256 id)); # only works for ids 0-65535
  genIpv6 = id: subnet: "fd${wgConfig.ula}:${toLowerHex subnet}::${toLowerHex id}";
  hostname = config.networking.hostName;

  enableWireguard = hasAttrByPath [ "hosts" hostname ] wgConfig;
  genIsServer = hn: (hasAttrByPath [ "hosts" hn "listen" ] wgConfig) && (hasAttrByPath [ "hosts" hn "domain" ] wgConfig);
  isServer = genIsServer hostname;
  netsThisHostIsIn = filter (x: elem hostname x.hosts) wgConfig.nets;

  getFilteredHosts = net: remove hostname net;
  filteredHosts = genFilteredHosts netsThisHostIsIn;
  genHostsOnlyServers = net: filter genIsServer net;
  hostsOnlyServers = genHostsOnlyServers netsThisHostIsIn;

  genPeersForNet = net:
  map (host:
    let
      h = wgConfig.hosts.${host};
      hServer = (hassAttrByPath [ "domain" ] h) && (hassAttrByPath [ "listen" ] h);
      hHasAdditional = (hassAttrByPath [ "additional_ip_ranges" ] h);
      additionalOfAllThisNet = flatten (map (x: if (hasAttrByPath [ "additional_ip_ranges" ] x) then x.additional_ip_ranges else []) filteredHosts);
    in
    {
      publicKey = h.pubkey;
      persistentKeepalive = if hServer then 25 else null;
      endpoint = if hServer then "${h.domain}:${h.listen}" else null;
      allowedIPs = [] ++ (if isServer then [
        "10.${toIpv4 net.id}.${toIpv4 h.id}/32"
        "${genIpv6 net.id h.id}/64"
      ] ++ (if hHasAdditional then h.additional_ip_ranges else []) else [
        "10.${toIpv4 net.id}.0.0/16"
      ] ++ additionalOfAllThisNet);



    }
  ) (if isServer then filteredHosts else hostsOnlyServers);
  genPeers = flatten (map genPeersForNet netsThisHostIsIn);

  genDNSforNet = net: map (x: [ (genIpv6 wgConfig.hosts.${x}.id net.id) "10.${toIpv4 net.id}.${toIpv4 wgConfig.hosts.${x}.id}" ]) (genHostsOnlyServers net);
  genDNS = flatten (map genDNSforNet netsThisHostIsIn);
in
{
  config = mkIf enableWireguard {
    networking.wg-quick.interfaces."wg0" = {
      privateKeyFile = "/run/secrets/rootWireguard${hostname}";
      listenPort = if isServer then getAttrByPath [ "hosts" hostname "listen" ] wgConfig else null;
      peers = getPeers;
      address = flatten 
        (map (x: ["${genIpv6 wgConfig.hosts.${hostname}.id x.id}/48" "10.${toIpv4 x.id}.${toIpv4 wgConfig.${hostname}.id}/16"]) netsThisHostIsIn);
      dns = if isServer then null else genDNS;
    };

    systemd.tmpfiles.rules = 
    let
      genHostsbyNameId = hn: hid: map (n: ''
        10.${toIpv4 n.id}.${toIpv4 hid} ${hn}.${n.domain}
        ${genIpv6 n.id hid} ${hn}.${n.domain}
      '') wgConfig.nets;
      hosts = concatStringsSep "\n" (map (h: genHostsbyNameId h wgConfig.hosts.${h}.id) (attrNames wgConfig.hosts));
      hostsfile = pkgs.writeTextFile "wg-hostfile" hosts;
    in
      [
        "L /run/wireguard-hosts - - - - ${hostsfile}"
      ];

    services.coredns.enable = (config.ragon.networking.router.enable == false);
    services.coredns.config = ''
      . {
        bind wg0
        hosts /run/wireguard-hosts
        forward . 1.1.1.1 1.0.0.1
      }
    '';

  };
}
