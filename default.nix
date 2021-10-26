{ inputs, config, lib, pkgs, ... }:

with lib;
with lib.my;
{
  imports = [ inputs.impermanence.nixosModules.impermanence ] ++ (mapModulesRec' (toString ./modules) import); # import ./modules/*

  # Set your time zone.
  time.timeZone = "Europe/Berlin";
  console.font = "Lat2-Terminus16";
  console.keyMap = "us";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_DK.UTF-8";
  };

  # Common config for all nixos machines; and to ensure the flake operates
  # soundly
  environment.variables.CONF = config.conf.dir;

  # Configure nix and nixpkgs
  environment.variables.NIXPKGS_ALLOW_UNFREE = "1";
  nix =
    let
      filteredInputs = filterAttrs (n: _: n != "self") inputs;
      nixPathInputs = mapAttrsToList (n: v: "${n}=${v}") filteredInputs;
      registryInputs = mapAttrs (_: v: { flake = v; }) filteredInputs;
    in
    {
      package = pkgs.unstable.nixFlakes;
      extraOptions = "experimental-features = nix-command flakes";
      trustedUsers = [ "root" "@wheel" ];
      nixPath = nixPathInputs ++ [
        "nixpkgs-overlays=${config.conf.dir}/overlays"
        "conf=${config.conf.dir}"
      ];
      binaryCaches = [
        "https://nix-community.cachix.org"
        "https://arm.cachix.org"
        "https://nix.hailsatan.eu"
      ];
      binaryCachePublicKeys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "arm.cachix.org-1:5BZ2kjoL1q6nWhlnrbAl+G7ThY7+HaBRD9PZzqZkbnM="
        "nix.hailsatan.eu:26eHAF8OR1sLUzwQ4WPDRlXBz1hB9nGlO5qAcRrbFtQ="
      ];
      registry = registryInputs // { conf.flake = inputs.self; };
      autoOptimiseStore = true;
    };
  system.configurationRevision = with inputs; mkIf (self ? rev) self.rev;
  system.stateVersion = "21.05";


  ## Some reasonable, global defaults
  # This is here to appease 'nix flake check' for generic hosts with no
  # hardware-configuration.nix or fileSystem config.
  fileSystems."/".device = mkDefault "/dev/disk/by-label/nixos";

  # Use a stable kernel as zfs is broken on latest
  boot = {
    #    kernelPackages = mkDefault pkgs.linux;
    loader = {
      efi.canTouchEfiVariables = mkDefault true;
      systemd-boot.configurationLimit = 10;
      systemd-boot.enable = mkDefault true;
    };
  };
}
