# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, ... }:

let
  secrets = import ../../data/load-secrets.nix;
  pubkeys = import ../../data/pubkeys.nix;
  sources = import ../../nix/sources.nix;
in
{
  imports =
    [
      # Include the results of the hardware scan.
      #      ./hardware-configuration.nix
      #      ./persistence.nix
      ../../modules
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_latest; # BLUTIGE ECKE
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "ds9"; # Define your hostname.
  nix.nixPath = [
    "nixpkgs=/etc/nixos/nix/nixos-unstable"
    "nixos-config=/etc/nixos/hosts/ds9/configuration.nix"
  ];

  # Disable root login for ssh
  services.openssh.permitRootLogin = "no";

  networking.useDHCP = false;
  networking.interfaces.eth0.useDHCP = true;
  #networking.networkmanager.enable = true;
  networking.hostId = "7b45236b";
  networking.firewall.enable = true;
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?


  # Immutable users due to tmpfs
  users.mutableUsers = false;

  # Set passwords
  users.users.root.initialHashedPassword = secrets.hashedRootPassword;
  users.users.ragon.initialHashedPassword = secrets.hashedRagonPassword;

  ragon.common-cli.enable = true;
  ragon.user.enable = true;
  ragon.auto-upgrade.enable = true;

  #  services.zfs.autoScrub.enable = true;

  #  boot = {
  #    initrd.network = {
  #      enable = true;
  #      ssh = {
  #         enable = true;
  #         port = 2222; 
  #         hostKeys = [ "/etc/ssh/ssh_host_rsa_key" "/etc/ssh/ssh_host_ed25519_key" ];
  #         authorizedKeys = pubkeys.ragon.computers;
  #      };
  #    };
  #  };

}
