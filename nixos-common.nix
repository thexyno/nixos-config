{ inputs, config, lib, pkgs, ... }:
with lib;
with lib.my;
let
  pubkeys = import ./data/pubkeys.nix;
in
{
  # Set your time zone.
  time.timeZone = "Europe/Berlin";
  console.font = "Lat2-Terminus16";
  console.keyMap = "us";

  users.users.root.openssh.authorizedKeys.keys = pubkeys.ragon.user;

  services.journald.extraConfig = ''
    SystemMaxUse=512M
  '';

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_DK.UTF-8";
  };

  # Configure nix and nixpkgs
  environment.variables.NIXPKGS_ALLOW_UNFREE = "1";
  nix =
    let
      filteredInputs = filterAttrs (n: _: n != "self") inputs;
      nixPathInputs = mapAttrsToList (n: v: "${n}=${v}") filteredInputs;
      registryInputs = mapAttrs (_: v: { flake = v; }) filteredInputs;
    in
    {
      package = pkgs.nixVersions.stable;
      settings = {
        trusted-users = mkDefault [ "root" "@wheel" ];
        allowed-users = mkDefault [ "root" "@wheel" ];
        substituters = [
          "https://nix-community.cachix.org"
        ];
        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
        auto-optimise-store = true;

      };
      extraOptions = "experimental-features = nix-command flakes";
      nixPath = nixPathInputs ++ [
      ];
      registry = registryInputs // { conf.flake = inputs.self; };
    };
  system.configurationRevision = with inputs; mkIf (self ? rev) self.rev;
  system.stateVersion = "22.05";


  ## Some reasonable, global defaults
  # This is here to appease 'nix flake check' for generic hosts with no
  # hardware-configuration.nix or fileSystem config.


  boot = {
    loader = {
      efi.canTouchEfiVariables = mkDefault true;
      systemd-boot.configurationLimit = 5;
    };
  };
}
