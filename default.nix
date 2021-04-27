{ inputs, config, lib, pkgs, ... }:

with lib;
with lib.my;
{
  imports = (mapModulesRec' (toString ./modules) import); # import ./modules/*

  # Common config for all nixos machines; and to ensure the flake operates
  # soundly
  environment.variables.CONF = config.conf.dir;

  # Configure nix and nixpkgs
  environment.variables.NIXPKGS_ALLOW_UNFREE = "1";
  nix =
    let filteredInputs = filterAttrs (n: _: n != "self") inputs;
        nixPathInputs  = mapAttrsToList (n: v: "${n}=${v}") filteredInputs;
        registryInputs = mapAttrs (_: v: { flake = v; }) filteredInputs;
    in {
      package = pkgs.nixFlakes;
      extraOptions = "experimental-features = nix-command flakes";
      nixPath = nixPathInputs ++ [
        "nixpkgs-overlays=${config.conf.dir}/overlays"
        "dotfiles=${config.conf.dir}"
      ];
      binaryCaches = [
        "https://nix-community.cachix.org"
      ];
      binaryCachePublicKeys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      registry = registryInputs // { conf.flake = inputs.self; };
      autoOptimiseStore = true;
    };
  system.configurationRevision = with inputs; mkIf (self ? rev) self.rev;
  system.stateVersion = "21.05";


  ## muh tmpfs
  # This is here to appease 'nix flake check' for generic hosts with no
  # hardware-configuration.nix or fileSystem config.
  fileSystems."/" =
    {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [ "size=8G" "defaults" "mode=755" ];
    };

  # Use the latest kernel
  boot = {
    kernelPackages = mkDefault pkgs.linuxPackages_latest;
    loader = {
      efi.canTouchEfiVariables = mkDefault true;
      systemd-boot.configurationLimit = 10;
      systemd-boot.enable = mkDefault true;
    };
  };


