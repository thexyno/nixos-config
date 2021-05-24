{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.services.home-assistant;
in
{
  config = lib.mkIf cfg.enable {
    # https://github.com/Mic92/dotfiles/tree/master/nixos/eve/modules/home-assistant for orientation
    services.home-assistant.lovelaceConfig = {
      title = "The mighty Citadel of Dundee";
      views = [
        { # dashboard
          title = "The Chaos Portal to the galactic nexus";
          cards = [

          ];

        }
      ];

    };
  };
}
