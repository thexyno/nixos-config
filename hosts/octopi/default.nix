{ config, inputs, pkgs, lib, ... }:
{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
  ];
  boot.loader.raspberryPi = {
    enable = true;
    version = 3;
  };
  boot.supportedFilesystems = lib.mkForce [ "reiserfs" "vfat" ]; # we dont need zfs here
  networking.hostId = "eec43f55";
  # networking.usePredictableInterfaceNames = false;
  documentation.enable = false;
  documentation.nixos.enable = false;

  nix = {
    autoOptimiseStore = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    # Free up to 1GiB whenever there is less than 100MiB left.
    extraOptions = ''
      min-free = ${toString (100 * 1024 * 1024)}
      max-free = ${toString (1024 * 1024 * 1024)}
    '';
  };
  powerManagement.cpuFreqGovernor = "ondemand";

  # Assuming this is installed on top of the disk image.
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  ragon.services.ssh.enable = true;
  ragon.services.octoprint.enable = true;
  ragon.services.ustreamer.enable = true;
  ragon.services.nginx.enable = true;
  ragon.nvim.enable = false;
  ragon.nvim.maximal = false;
  programs.gnupg.agent.enable = false;
  ragon.cli.enable = true;
  ragon.cli.maximal = false;
  services.lorri.enable = false;
  security.sudo.wheelNeedsPassword = false;
}
