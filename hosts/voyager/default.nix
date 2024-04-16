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

  programs.mosh.enable = true;
  security.sudo.wheelNeedsPassword = false;
  networking.useDHCP = true;

  services.xserver.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  environment.systemPackages = [
    pkgs.whipper
  ];

  home-manager.users.ragon = { pkgs, lib, inputs, config, ... }: {
    imports = [
      ../../hm-modules/nvim
      ../../hm-modules/zsh
      ../../hm-modules/tmux
      ../../hm-modules/xonsh
      ../../hm-modules/cli.nix
      ../../hm-modules/files.nix
    ];
    ragon.xonsh.enable = true;

    programs.home-manager.enable = true;
    home.stateVersion = "23.11";
  };

  ragon = {
    user.enable = true;
    services = {
      ssh.enable = true;
      tailscale.enable = true;
    };

  };
}
