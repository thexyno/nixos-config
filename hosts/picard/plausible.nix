{ config, lib, pkgs, ... }:
let domain = "stats.xyno.space";
in {
  ragon.agenix.secrets."plausibleAdminPw" = { };
  ragon.agenix.secrets."plausibleReleaseCookie" = { };
  ragon.agenix.secrets."plausibleSecretKeybase" = { };
  ragon.agenix.secrets."smtpPassword.age" = { };
  services.nginx.virtualHosts.${domain} = {
    forceSSL = true;
    enableACME = true;
    locations."/".proxyPass =
      "http://127.0.0.1:${toString config.services.plausible.server.port}";
  };
  services.plausible = {
    enable = true;
    releaseCookiePath = config.age.secrets.plausibleSecretKeybase.path;

    adminUser = {
      # activate is used to skip the email verification of the admin-user that's
      # automatically created by plausible. This is only supported if
      # postgresql is configured by the module. This is done by default, but
      # can be turned off with services.plausible.database.postgres.setup.
      activate = true;
      email = "john.doe@example.com";
      passwordFile = config.age.secrets.plausibleAdminPw.path;
    };

    server = {
      baseUrl = "https://${domain}";
      secretKeybaseFile = config.age.secrets.plausibleSecretKeybase.path;
    };
    mail.email = "machdas@xyno.space";
    mail.smtp = {
      user = "machdas@xyno.space";
      passwordFile = config.age.secrets.smtpPassword.path;
      hostAddr = "smtp.ionos.de";
      hostPort = 465;
      enableSSL = true;
    };
  };

  ragon.persist.extraDirectories = [ "/var/lib/private/plausible" ];
}
