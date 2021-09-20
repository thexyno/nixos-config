# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ lib, modulesPath, config, pkgs, builtins, ... }:
{
  imports =
    [
    "${modulesPath}/installer/cd-dvd/iso-image.nix"
    "${modulesPath}/profiles/headless.nix"
    "${modulesPath}/profiles/minimal.nix"
    "${modulesPath}/profiles/qemu-guest.nix"
    ];
  fileSystems."/".device = "tmpfs";
  isoImage.isoName = "${config.isoImage.isoBaseName}-${config.system.nixos.label}-${config.networking.hostName}.iso";
  ragon.agenix.enable = false;
  services.sshd.enable = true;
  users.users.root.openssh.authorizedKeys.keys = pkgs.pubkeys.ragon.computers;
  isoImage.makeEfiBootable = true;
  isoImage.makeUsbBootable = true;
  networking.interfaces.enp1s0.useDHCP = true;
  environment.defaultPackages = lib.mkForce [];


  ragon.router = {
    internalInterface = "enp2s0";
    externalInterface = "wg0";
    enable = true;
  };

  networking.wg-quick.interfaces.wg0 = {
    privateKeyFile = "/tmp/wireguardKey";
    address = [ "10.68.144.1/32" "fc00:bbbb:bbbb:bb01::5:9000/128" ];
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
      publicKey = "StMPmol1+QQQQCJyAkm7t+l/QYTKe5CzXUhw0I6VX14=";
      allowedIPs = [ "0.0.0.0/0" "::0/0" ];
      endpoint = "92.60.40.194:51820";
    }];
  };
}

