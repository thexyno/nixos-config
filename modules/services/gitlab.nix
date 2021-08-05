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

    ragon.agenix.secrets = foldl (a: b: a // b) { } (map (a: { ${a} = { owner = "gitlab"; }; }) [
      "gitlabDBFile"
      "gitlabInitialRootPassword"
      "gitlabJWSFile"
      "gitlabOTPFile"
      "gitlabSecretFile"
    ]);

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
