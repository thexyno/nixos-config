{ config, lib, pkgs, ... }:
with lib;
with lib.my;
let
  cfg = config.ragon.services.gitlab;
  domain = config.ragon.services.nginx.domain;
in
{
  options.ragon.services.gitlab.enable = mkEnableOption "Enables gitlab";
  options.ragon.services.gitlab.domainPrefix =
    mkOption {
      type = lib.types.str;
      default = "gitlab";
    };
  config = lib.mkIf cfg.enable {
    services.gitlab = {
      enable = true;
      https = true;
      initialRootPasswordFile = "/run/secrets/gitlabInitialRootPassword";
      secrets = {
        dbFile = "/run/secrets/gitlabDBFile";
        jwsFile = "/run/secrets/gitlabJWSFile";
        otpFile = "/run/secrets/gitlabOTPFile";
        secretFile = "/run/secrets/gitlabSecretFile";
      };
    };

    age.secrets = {
      gitlabDBFile.owner = "gitlab";
      gitlabInitialRootPassword.owner = "gitlab";
      gitlabJWSFile.owner = "gitlab";
      gitlabOTPFile.owner = "gitlab";
      gitlabSecretFile.owner = "gitlab";
    };




    services.nginx.virtualHosts."${cfg.domainPrefix}.${domain}" = {
    useACMEHost = "${domain}";
    forceSSL = true;
    locations."/".proxyPass = "http://unix:/run/gitlab/gitlab-workhorse.socket";
  };
    ragon.persist.extraDirectories = [
      "${config.services.postgresql.dataDir}"
      "${config.services.gitlab.statePath}"
    ];
  };
}
