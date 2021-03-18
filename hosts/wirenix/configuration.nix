# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  secrets = import ../../data/load-secrets.nix;
  sources = import ../../nix/sources.nix;
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./persistence.nix
      ../../modules
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "wirenix"; # Define your hostname.
  nix.nixPath = [
    "nixpkgs=/etc/nixos/nix/nixos-unstable"
    "nixos-config=/etc/nixos/hosts/wirenix/configuration.nix"
  ];
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  #
  # Disable root login for ssh
  services.openssh.permitRootLogin = "no";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.ens18.useDHCP = true;
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neovim wireguard-tools
  ];

  # Immutable users due to tmpfs
  users.mutableUsers = false;

  # Set passwords
  users.users.root.initialHashedPassword = secrets.hashedRootPassword;
  users.users.satan.initialHashedPassword = secrets.hashedRagonPassword;

  ragon.common-cli.enable = true;
  ragon.user.enable = true;
  ragon.user.username = "satan";
  ragon.nvim.enable = false;
  ragon.auto-upgrade.enable = true;

  ragon.router = {
    internalInterface = "ens19";
    externalInterface = "wg0";
    enable = true;
  };

  environment.etc."wireguard_key" = {
    text = secrets.wirenixWgPrivateKey;
    mode = "0400";
  }

  networking.wg-quick.interfaces.wg0 = {
      privateKeyFile = "/etc/wireguard_key";
      address = [ "10.65.203.192/32"  "fc00:bbbb:bbbb:bb01::2:cbbf/128"];
      dns = ["193.138.218.74"];
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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

}

