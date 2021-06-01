{ inputs, config, lib, pkgs, ... }:

with lib;
with lib.my;
{
  imports = [ inputs.impermanence.nixosModules.impermanence ] ++ (mapModulesRec' (toString ./modules) import); # import ./modules/*

  # Set passwords
  users.users.root. passwordFile = "${config.age.secrets.rootPasswd.path}";
  users.users.ragon.passwordFile = "${config.age.secrets.rootRagonPasswd.path}";
  # Set your time zone.
  time.timeZone = "Europe/Berlin";
  console.font = "Lat2-Terminus16";
  console.keyMap = "de";

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


  ## Some reasonable, global defaults
  # This is here to appease 'nix flake check' for generic hosts with no
  # hardware-configuration.nix or fileSystem config.
  fileSystems."/".device = mkDefault "/dev/disk/by-label/nixos";

  # Use the latest kernel
  boot = {
    kernelPackages = mkDefault pkgs.linuxPackages_5_11;
    loader = {
      efi.canTouchEfiVariables = mkDefault true;
      systemd-boot.configurationLimit = 10;
      systemd-boot.enable = mkDefault true;
    };
  };
}
