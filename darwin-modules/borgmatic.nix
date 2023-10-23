{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.ragon.services.borgmatic;
  settingsFormat = pkgs.formats.yaml { };
  cfgType = with types; submodule {
    freeformType = settingsFormat.type;
    options.location = {
      source_directories = mkOption {
        type = listOf str;
        description = mdDoc ''
          List of source directories to backup (required). Globs and
          tildes are expanded.
        '';
        example = [ "/home" "/etc" "/var/log/syslog*" ];
      };
      repositories = mkOption {
        type = listOf str;
        description = mdDoc ''
          Paths to local or remote repositories (required). Tildes are
          expanded. Multiple repositories are backed up to in
          sequence. Borg placeholders can be used. See the output of
          "borg help placeholders" for details. See ssh_command for
          SSH options like identity file or port. If systemd service
          is used, then add local repository paths in the systemd
          service file to the ReadWritePaths list.
        '';
        example = [
          "ssh://user@backupserver/./sourcehostname.borg"
          "ssh://user@backupserver/./{fqdn}"
          "/var/local/backups/local.borg"
        ];
      };
    };
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

    environment.systemPackages = [ pkgs.borgmatic ];

    environment.etc = (optionalAttrs (cfg.settings != null) { "borgmatic/config.yaml".source = cfgfile; }) //
      mapAttrs'
        (name: value: nameValuePair
          "borgmatic.d/${name}.yaml"
          { source = settingsFormat.generate "${name}.yaml" value; })
        cfg.configurations;

    launchd.agents.borgmatic = {
      script = "borgmatic";
      serviceConfig = {
        StartInterval = 60 * 60; # run every hour
        label = "xyz.ragon.borgmatic";
        StandardOutPath = "/var/log/borgmatic.log";
        StandardErrorPath = "/var/log/borgmatic.log.error";
        NetworkState = true;
        Nice = 1;
      };
    };
  };


}
