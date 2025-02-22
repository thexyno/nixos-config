{ pkgs, config, lib, ... }:
let
  cfg = config.xyno.desktop.mako;
  makoConf = pkgs.writeText "mako.conf" ''
    font=Source Sans Pro Nerd Font 11
    background-color=#1d2021ff
    border-color=#3c3836FF
    text-color=#ebdbb2ff
    progress-color=over #928374FF
  '';
in
{
  options.xyno.desktop.mako.enable = lib.mkEnableOption "enable mako notification daemon";
  options.xyno.desktop.mako.wantedBy = lib.mkOption {
    type = lib.types.str;
    default = "niri.service";
  };
  options.xyno.desktop.mako.package = lib.mkOption {
    type = lib.types.package;
    default = pkgs.mako;
  };
  config = lib.mkIf cfg.enable {
    systemd.user.services.mako = {
      wantedBy = [ cfg.wantedBy ];
      script = "${cfg.package}/bin/mako -c ${makoConf}";
      restartTrigers = makoConf;
    };

  };
}
