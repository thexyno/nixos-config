{ config, inputs, pkgs, lib, ... }:
{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
  ];
  boot = {
    kernelPackages = pkgs.linuxPackages_5_11;
  };
  boot.loader.raspberryPi = {
    enable = true;
    version = 4;
  };
  networking.hostId = "eec43f51";
  networking.usePredictableInterfaceNames = false;

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

  ragon.user.enable = true;
  ragon.networking.router.enable = true;
  ragon.services.ssh.enable = true;
  ragon.nvim.enable = false;
  programs.gnupg.agent.enable = true;
  ragon.cli.enable = true;
  services.lorri.enable = false;

}
