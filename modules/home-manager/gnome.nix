{ inputs, config, lib, pkgs, ... }:
let
  cfg = config.ragon.home-manager;
  isGui = config.ragon.gui.enable;
in
{
  config = lib.mkIf (cfg.enable && config.ragon.gui.gnome.enable) {
    home-manager.users.${config.ragon.user.username} = { pkgs, lib, ... }:
    {
    };
  };
}
