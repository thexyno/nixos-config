{ config, inputs, pkgs, lib, ... }:
{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
  ];

  boot.supportedFilesystems = lib.mkForce [ "reiserfs" "vfat" ]; # we dont need zfs here
  boot.loader.systemd-boot.enable = false;
  networking.hostId = "eec43f55";
  # networking.usePredictableInterfaceNames = false;
  documentation.enable = false;
  documentation.nixos.enable = false;
  # Assuming this is installed on top of the disk image.
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.systemWide = true;
  hardware.pulseaudio.tcp.enable = true;
  hardware.pulseaudio.zeroconf.publish.enable = true;
  services.shairport-sync.enable = true;
  services.shairport-sync.openFirewall = true;
  services.shairport-sync.group = "audio";
  hardware.pulseaudio.tcp.anonymousClients.allowedIpRanges = [ "127.0.0.1" "10.0.0.0/8" ];
  ragon.services.ssh.enable = true;
  ragon.nvim.enable = false;
  ragon.nvim.maximal = false;
  programs.gnupg.agent.enable = false;
  ragon.cli.enable = false;
  ragon.cli.maximal = false;
  services.lorri.enable = false;
  security.sudo.wheelNeedsPassword = false;
}
