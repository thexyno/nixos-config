{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.services.home-assistant;
in
{
  config = lib.mkIf cfg.enable {
    # https://github.com/Mic92/dotfiles/tree/master/nixos/eve/modules/home-assistant for orientation
    services.home-assistant.config = {
      zha = {
        zigpy_config.ota = { # auto update for ikea and ledvance (osram) stuff
          ikea_provider = true;
          ledvance_provider = true;
        };

      };
    };
  };
}
