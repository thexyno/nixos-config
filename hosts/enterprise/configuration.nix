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
      ./hardware-configuration.nix
      ./persistence.nix
      ../../modules
    ];

  # Use the systemd-boot EFI boot loader.
  # boot.loader.systemd-boot.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_latest; # BLUTIGE ECKE
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    ipxe.netbootxyz = ''
      #!ipxe
      dhcp
      chain --autofree https://boot.netboot.xyz/ipxe/netboot.xyz.efi
    '';
    efiSupport = true;
    useOSProber = true;
    device = "nodev";
  };


  services.xserver.videoDrivers = [ "nvidia" ];

  networking.hostName = "enterprise"; # Define your hostname.
  nix.nixPath = [
    "nixpkgs=/etc/nixos/nix/nixos-unstable"
    "nixos-config=/etc/nixos/hosts/enterprise/configuration.nix"
  ];

  # Disable root login for ssh
  services.openssh.permitRootLogin = "no";


  networking.useDHCP = false;
  networking.networkmanager.enable = true;
  networking.hostId = "7b45236a";

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
  ragon.home-manager.enable = true;
  ragon.gui.enable = true;
  ragon.auto-upgrade.enable = true;
  ragon.gamingvmhost.enable = true;
  ragon.develop.enable = true;
  ragon.prometheus.enable = true;
  ragon.cli.pandoc.enable = true;
  ragon.prometheus.mode = [ "master" "node"];

  environment.etc."smb-secrets" = {
    text = secrets.smbSecret;
    mode = "0400";
  };

  services.zfs.autoScrub.enable = true;

  services.sanoid = {
    enable = true;
    datasets."pool/persist" = {};
  };
  services.syncoid = {
    sshKey = /root/.ssh/id_rsa;
    enable = true;
    commands."pool/persist" = {
      target = "root@pve:data/Backups/enterprise";
      recvOptions = "x encryption";
    };
  };
  #services.znapzend = {
  #  enable = true;
  #  pure = true;
  #  features.compressed = true;
  #  autoCreation = true;
  #  zetup = {
  #    "pool/persist" = {
  #      # Make snapshots of tank/home every hour, keep those for 1 day,
  #      # keep every days snapshot for 1 month, etc.
  #      plan = "1d=>1h,1m=>1d,1y=>1m";
  #      recursive = true;
  #      # Send all those snapshots to john@example.com:rtank/john as well
  #      destinations.remote = {
  #        host = "root@pve";
  #        dataset = "-x encryption data/Backups/enterprise";
  #      };
  #    };
  #  };
  #};

  # does not work
  #boot = {
  #  initrd.network = {
  #    enable = true;
  #    ssh = {
  #       enable = true;
  #       port = 2222; 
  #       hostKeys = [ "/etc/ssh/ssh_host_rsa_key" "/etc/ssh/ssh_host_ed25519_key" ];
  #       authorizedKeys = pubkeys.ragon.computers;
  #    };
  #  };
  #};


  fileSystems."/media/data" = {
    device = "//10.0.0.2/data";
    fsType = "cifs";
    options = let
        # this line prevents hanging on network split
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
      in ["${automount_opts},credentials=/etc/smb-secrets,uid=1000,gid=1"];

  };


}
