{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.services.home-assistant;
in
{
  config = lib.mkIf cfg.enable {
    # Ideen für Namen von stuff
    # - The Land Of Unicorns (Küche maybe)
    services.home-assistant.lovelaceConfig = {
      title = "The mighty Citadel of Dundee";
      views = [
        {
          # dashboard
          title = "The Chaos Portal to the galactic nexus";
          cards = [

          ];

        }
      ];

    };
  };
}
