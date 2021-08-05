# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, builtins, ... }:
{
  imports =
    [
      ../iso/default.nix
    ];

  networking.interfaces.ens18.useDHCP = true;

  ragon.router = {
    internalInterface = "ens19";
    externalInterface = "wg0";
    enable = true;
  };

  environment.etc."wireguard_key" = {
    text = builtins.readFile ./wgKey;
    mode = "0400";
  };

  networking.wg-quick.interfaces.wg0 = {
    privateKeyFile = "/etc/wireguard_key";
    address = [ "10.65.203.192/32" "fc00:bbbb:bbbb:bb01::2:cbbf/128" ];
    dns = [ "193.138.218.74" ];
    postUp = ''
      ${pkgs.iptables}/bin/iptables -I OUTPUT -o wg0 -m mark ! --mark $(wg show wg0 fwmark) -m addrtype ! --dst-type LOCAL -j REJECT
      ${pkgs.iptables}/bin/ip6tables -I OUTPUT ! -o wg0 -m mark ! --mark $(wg show wg0 fwmark) -m addrtype ! --dst-type LOCAL -j REJECT
    '';
    preDown = ''
      ${pkgs.iptables}/bin/iptables -D OUTPUT ! -o wg0 -m mark ! --mark $(wg show wg0 fwmark) -m addrtype ! --dst-type LOCAL -j REJECT
      ${pkgs.iptables}/bin/ip6tables -D OUTPUT ! -o wg0 -m mark ! --mark $(wg show wg0 fwmark) -m addrtype ! --dst-type LOCAL -j REJECT
    '';

    peers = [{
      publicKey = "hnRyse6QxPPcZOoSwRsHUtK1W+APWXnIoaDTmH6JsHQ=";
      allowedIPs = [ "0.0.0.0/0" "::0/0" ];
      endpoint = "193.32.249.69:51820";
    }];
  };
}

