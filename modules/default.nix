{ pkgs, ... }:

let
  # Load sources
  sources = import ../nix/sources.nix;
in {
  imports = [
    ./auto-upgrade.nix
    ./common-cli.nix
    ./common-gui.nix
    ./nvim.nix
    ./home-manager.nix
    ./user.nix
    ./gamingvmhost.nix
  ];
}

