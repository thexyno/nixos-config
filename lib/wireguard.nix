{ lib, ... }:
with builtins;
with lib;
{
  genWgConf = hostname:
  let
    wgConfig = importTOML ../data/wireguard.toml;
    toLowerHex = id: toLower (toHexString id); # only works for ids 0-65535
    toIpv4 = id:
      let
        a = builtins.concatStringsSep "." (map toString (toBaseDigits 256 id));
      in
      if id < 256 then "0.${a}" else a; # only works for ids 0-65535
    genIpv6 = id: subnet: "fd${wgConfig.ula}:${toLowerHex subnet}::${toLowerHex id}";

    enableWireguard = (hasAttrByPath [ "hosts" hostname ] wgConfig && wgConfig.hosts.${hostname}.pubkey != "a");
    genIsServer = hn: (hasAttrByPath [ "hosts" hn "listen" ] wgConfig) && (hasAttrByPath [ "hosts" hn "domain" ] wgConfig);
    isServer = genIsServer hostname;
    netsThisHostIsIn = filter (x: elem hostname x.hosts) (attrValues wgConfig.nets);

    combineNetstoOneHostList = nets: flatten (map (x: x.hosts) nets);
    genFilteredHosts = nets: lib.lists.remove hostname (combineNetstoOneHostList nets);
    filteredHosts = genFilteredHosts netsThisHostIsIn; # List of Lists of hosts in which nets our host is in without our host itself
    genHostsOnlyServers = net: filter genIsServer (combineNetstoOneHostList net);
    hostsOnlyServers = genHostsOnlyServers netsThisHostIsIn;

    genPeersForNet =
      let
        toUse = if isServer then filteredHosts else hostsOnlyServers;
      in
      net: map
        (host:
          let
            h = wgConfig.hosts.${host};
            hServer = (hasAttrByPath [ "domain" ] h) && (hasAttrByPath [ "listen" ] h);
            hHasAdditional = (hasAttrByPath [ "additional_ip_ranges" ] h);
            additionalOfAllThisNet = flatten (map (x: if (hasAttrByPath [ "additional_ip_ranges" ] wgConfig.hosts.${x}) then wgConfig.hosts.${x}.additional_ip_ranges else [ ]) filteredHosts);
          in
          {
            publicKey = h.pubkey;
            persistentKeepalive = if hServer then 25 else null;
            endpoint = if hServer then "${h.domain}:${toString h.listen}" else null;
            allowedIPs = (if isServer then [
              "10.${toString net.id}.${toIpv4 h.id}/32"
              "${genIpv6 h.id net.id}/128"
            ] ++ (if hHasAdditional then h.additional_ip_ranges else [ ]) else [
              "10.${toString net.id}.0.0/16"
            ] ++ additionalOfAllThisNet);
          }
        )
        toUse;
    genPeers = flatten (map genPeersForNet netsThisHostIsIn);

    genDNSforNet = net: map (x: [ (genIpv6 wgConfig.hosts.${x}.id net.id) "10.${toString net.id}.${toIpv4 wgConfig.hosts.${x}.id}" ]) (genHostsOnlyServers [ net ]);
    genDNS = flatten (map genDNSforNet netsThisHostIsIn);
  in {
    inherit isServer;
    enable = enableWireguard;
    interfaceConfig = 
      let
        port = if isServer then wgConfig.hosts.${hostname}.listen else null;
      in
      {
        privateKeyFile = "/run/secrets/wireguard${hostname}";
        listenPort = port;
        peers = genPeers;
        address = flatten
          (map (x: [ "${genIpv6 wgConfig.hosts.${hostname}.id x.id}/64" "10.${toString x.id}.${toIpv4 wgConfig.hosts.${hostname}.id}/16" ]) netsThisHostIsIn);
        dns = if isServer then [ ] else genDNS;
      };

        hostsFile = 
      let
        genHostsbyNameId = hn: hid: map
          (n: ''
            10.${toString n.id}.${toIpv4 hid} ${hn}.${n.domain}
            ${genIpv6 hid n.id} ${hn}.${n.domain}
          '')
          (attrValues wgConfig.nets);
        hosts = concatStringsSep "\n" (flatten (map (h: genHostsbyNameId h wgConfig.hosts.${h}.id) (attrNames wgConfig.hosts)));
      in
        hosts = hosts;
  };
}
