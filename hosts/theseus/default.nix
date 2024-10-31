{ config, inputs, pkgs, lib, ... }:
{
  imports =
    [
      ./hardware-configuration.nix

      ../../nixos-modules/networking/tailscale.nix
      ../../nixos-modules/services/ssh.nix
      ../../nixos-modules/system/agenix.nix
      ../../nixos-modules/system/persist.nix
      ../../nixos-modules/user
    ];

  # Don't Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.initrd.luks.devices.cryptroot.device = "/dev/disk/by-uuid/4cd8dbb3-8eea-48ff-87b1-92945be291ac";
  programs.sway.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  environment.systemPackages = [
    pkgs.wezterm
  ];

  home-manager.users.ragon = { pkgs, lib, inputs, config, ... }: {
    imports = [
      ../../hm-modules/helix
      ../../hm-modules/nushell
      ../../hm-modules/cli.nix
      ../../hm-modules/files.nix
    ];
    ragon.helix.enable = true;
    ragon.nushell.enable = true;

    programs.home-manager.enable = true;
    home.stateVersion = "24.05";
  };

  ragon = {
    user.enable = true;
    services = {
      ssh.enable = true;
      tailscale.enable = true;
    };

  };
}
