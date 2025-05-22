{ config, lib, pkgs, ... }:
let domain = "stats.xyno.space";
in {
  ragon.agenix.secrets."plausibleAdminPw" = { };
  ragon.agenix.secrets."plausibleReleaseCookie" = { };
  ragon.agenix.secrets."plausibleSecretKeybase" = { };
  ragon.agenix.secrets."plausibleGoogleClientId" = { };
  ragon.agenix.secrets."plausibleGoogleClientSecret" = { };
  ragon.agenix.secrets."smtpPassword" = { };
  systemd.services.plausible.serviceConfig.LoadCredential = [
    "GOOGLE_CLIENT_ID:${config.age.secrets.plausibleGoogleClientId.path}"
    "GOOGLE_CLIENT_SECRET:${config.age.secrets.plausibleGoogleClientSecret.path}"
  ];
  systemd.services.plausible.environment = {
    IP_GEOLOCATION_DB = "${pkgs.unstable.dbip-country-lite}/share/dbip/dbip-country-lite.mmdb";
    DATABASE_URL = "postgresql:///plausible?host=/run/postgresql";
  };
  systemd.services.plausible.script =
  let cfg = config.services.plausible; in lib.mkForce ''
                # Elixir does not start up if `RELEASE_COOKIE` is not set,
            # even though we set `RELEASE_DISTRIBUTION=none` so the cookie should be unused.
            # Thus, make a random one, which should then be ignored.
            export RELEASE_COOKIE=$(tr -dc A-Za-z0-9 < /dev/urandom | head -c 20)
            export ADMIN_USER_PWD="$(< $CREDENTIALS_DIRECTORY/ADMIN_USER_PWD )"
            export SECRET_KEY_BASE="$(< $CREDENTIALS_DIRECTORY/SECRET_KEY_BASE )"

            ${lib.optionalString (
              cfg.mail.smtp.passwordFile != null
            ) ''export SMTP_USER_PWD="$(< $CREDENTIALS_DIRECTORY/SMTP_USER_PWD )"''}

            echo setup
            ${lib.optionalString cfg.database.postgres.setup ''
              # setup
              ${cfg.package}/createdb.sh
            ''}

            echo migrate
            ${cfg.package}/migrate.sh
            export IP_GEOLOCATION_DB=${pkgs.dbip-country-lite}/share/dbip/dbip-country-lite.mmdb
            # ${cfg.package}/bin/plausible eval "(Plausible.Release.prepare() ; Plausible.Auth.create_user(\"$ADMIN_USER_NAME\", \"$ADMIN_USER_EMAIL\", \"$ADMIN_USER_PWD\"))"
            ${lib.optionalString cfg.adminUser.activate ''
              psql -d plausible <<< "UPDATE users SET email_verified=true where email = '$ADMIN_USER_EMAIL';"
            ''}

            echo start
            exec plausible start
      
    '';
  services.plausible = {
    enable = true;
    package = pkgs.unstable.plausible;
    # releaseCookiePath = config.age.secrets.plausibleSecretKeybase.path;

    adminUser = {
      # activate is used to skip the email verification of the admin-user that's
      # automatically created by plausible. This is only supported if
      # postgresql is configured by the module. This is done by default, but
      # can be turned off with services.plausible.database.postgres.setup.
      activate = true;
      email = "plausible@xyno.space";
      passwordFile = config.age.secrets.plausibleAdminPw.path;
    };

    server = {
      baseUrl = "https://${domain}";
      secretKeybaseFile = config.age.secrets.plausibleSecretKeybase.path;
    };
    mail.email = "plausible@hailsatan.eu";
    mail.smtp = {
      user = "plausible@hailsatan.eu";
      passwordFile = config.age.secrets.smtpPassword.path;
      hostAddr = "mail.hailsatan.eu";
      hostPort = 465;
      enableSSL = true;
    };
  };

  ragon.persist.extraDirectories = [ "/var/lib/private/plausible" "/var/lib/clickhouse" ];
}
