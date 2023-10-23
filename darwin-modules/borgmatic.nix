{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.ragon.services.borgmatic;
  settingsFormat = pkgs.formats.yaml { };
  cfgType = with types; submodule {
    freeformType = settingsFormat.type;
  };
  cfgfile = settingsFormat.generate "config.yaml" cfg.settings;
in
{
  options.ragon.services.borgmatic = {
    enable = mkEnableOption (mdDoc "borgmatic");

    settings = mkOption {
      description = mdDoc ''
        See https://torsion.org/borgmatic/docs/reference/configuration/
      '';
      default = null;
      type = types.nullOr cfgType;
    };

    configurations = mkOption {
      description = mdDoc ''
        Set of borgmatic configurations, see https://torsion.org/borgmatic/docs/reference/configuration/
      '';
      default = { };
      type = types.attrsOf cfgType;
    };
  };
  config = mkIf cfg.enable {

    environment.systemPackages = [
      #pkgs.borgmatic
      pkgs.borgbackup
    ];
    homebrew.brews = [ "borgmatic" ];

    environment.etc = (optionalAttrs (cfg.settings != null) { "borgmatic/config.yaml".source = cfgfile; }) //
      mapAttrs'
        (name: value: nameValuePair
          "borgmatic.d/${name}.yaml"
          { source = settingsFormat.generate "${name}.yaml" value; })
        cfg.configurations;

    launchd.user.agents.borgmatic = {
      script = ''
        if (pmset -g batt | grep -q 'AC Power'); then
          borgmatic
        else
          echo "On Battery Power, skipping backup"
        fi
      '';
      path = [ "/opt/homebrew/bin" config.environment.systemPath ];
      serviceConfig = {
        StartInterval = 60 * 60; # run every hour
        StandardOutPath = "/var/log/borgmatic.log";
        StandardErrorPath = "/var/log/borgmatic.log";
        KeepAlive = true;
        # NetworkState = true;
        Nice = 1;
      };
    };
    assertions = [
      {
        assertion = config.homebrew.enable;
        message = "homebrew must be enabled for borgmatic to run";
      }
    ];
  };


}
