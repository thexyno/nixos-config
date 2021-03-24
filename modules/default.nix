{ pkgs, ... }:

let
  # Load sources
  sources = import ../nix/sources.nix;
in {
  imports = [
    "${sources.impermanence}/nixos.nix"
    ./auto-upgrade.nix
    ./common-cli.nix
    ./common-gui.nix
    ./nvim.nix
    ./develop.nix
    ./router.nix
    ./home-manager.nix
    ./user.nix
    ./gamingvmhost.nix
    ./prometheus.nix
  ];
}

