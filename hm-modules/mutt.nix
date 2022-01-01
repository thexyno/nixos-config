{ inputs, config, lib, pkgs, ... }:
let
  cfg = config.ragon.home-manager;
in
{
  config = lib.mkIf cfg.enable {
    # Make sure to start the home-manager activation before I log it.
    hom.systemPackages = with pkgs;[
      neomutt
    ];
    accounts.email
      };
      }
