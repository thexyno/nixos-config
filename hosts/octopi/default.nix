{ config, inputs, pkgs, lib, ... }:
{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
    "${inputs.nixos-hardware}/raspberry-pi/4/default.nix"
  ];
  nixpkgs.overlays = [
    (final: super: {
      makeModulesClosure = x:
        super.makeModulesClosure (x // { allowMissing = true; });
    })
  ];
  boot.loader.systemd-boot.enable = false;
  boot.kernelPackages = pkgs.linuxPackages_rpi4;
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
  ragon.services.tailscale.enable = true;
  networking.useDHCP = true;
  services.mjpg-streamer.enable = true;
  services.mjpg-streamer.inputPlugin = "input_uvc.so -d /dev/video0 -r 1280x720 -f 15 -u";
  services.octoprint = {
    enable = true;
    plugins = plugins: with plugins; [ telegram ];
  };
  security.sudo.wheelNeedsPassword = false;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIkFgHr6OMwsnGhdG4TwKdthlJC/B9ELqZfrmJ9Sf7qk"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH8RjUQ6DDDDgsVbqq+6zz1q6cBkus/BLUGa9JoWsqB4"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIkNP8Lo20fw3Ysq3B64Iep9WyVKWxdv5KJOZRLmAaaM"
  ];


}
