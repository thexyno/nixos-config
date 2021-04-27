# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ age, pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./persistence.nix
    ];

  # Don't Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = false;
  # grubbi grub grub
  boot.loader.grub = {
    efiSupport = true;
    useOSProber = true;
    device = "nodev";
  };


  # nivea
  services.xserver.videoDrivers = [ "nvidia" ];

  # Disable root login for ssh TODO move this elsewhere
  services.openssh.permitRootLogin = "no";

  networking.useDHCP = false;
  networking.networkmanager.enable = true;
  networking.hostId = "7b45236a";

  # Immutable users due to tmpfs
  users.mutableUsers = false;

  # Set passwords
  age.secrets.ragonpasswd.file = ../../secrets/ragonpasswd.age;
  age.secrets.rootpasswd.file = ../../secrets/rootpasswd.age;
  users.users.root.passwordFile =  age.secrets.rootpasswd.path;
  users.users.ragon.passwordFile = age.secrets.ragonpasswd.path;

  ragon.common-cli.enable = true;
  ragon.user.enable = true;
  ragon.home-manager.enable = true;
  ragon.gui.enable = true;
  ragon.abcde.enable = true;
  ragon.auto-upgrade.enable = true;
  ragon.gamingvmhost.enable = true;
  ragon.develop.enable = true;
  ragon.prometheus.enable = true;
  ragon.persist.enable = true;
  ragon.cli.pandoc.enable = true;
  ragon.prometheus.mode = [ "master" "node" ];
  virtualisation.docker.enable = true;


  services.zfs.autoScrub.enable = true;

  services.sanoid = {
    enable = true;
    datasets."pool/persist" = { };
  };
  services.syncoid = {
    user = "root";
    group = "root";
    sshKey = /persistent/root/.ssh/id_rsa;
    enable = true;
    commonArgs = [
    ];
    commands."pool/persist" = {
      target = "root@pve:data/Backups/enterprise";
      recvOptions = "x encryption";

    };
  };

  age.secrets.smb.file = ../../secrets/smb.age;
  fileSystems."/media/data" = {
    device = "//10.0.0.2/data";
    fsType = "cifs";
    options =
      let
        # this line prevents hanging on network split
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
      in
      [ "${automount_opts},credentials=/run/secrets/smb,uid=1000,gid=1" ];

  };


}
