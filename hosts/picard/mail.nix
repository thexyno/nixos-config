{
  pkgs,
  config,
  lib,
  ...
}:
{
  virtualisation.oci-containers.containers."mail" = {
    image = "ghcr.io/docker-mailserver/docker-mailserver:latest";
    hostname = "mail.hailsatan.eu";
    ports = [
      "25:25" # SMTP  (explicit TLS => STARTTLS, Authentication is DISABLED => use port 465/587 instead)
      "143:143" # IMAP4 (explicit TLS => STARTTLS)
      "465:465" # ESMTP (implicit TLS)
      "587:587" # ESMTP (explicit TLS => STARTTLS)
      "993:993" # IMAP4 (implicit TLS)
    ];
    volumes = [
      "mail-data:/var/mail/"
      "mail-state:/var/mail-state/"
      "mail-logs:/var/log/mail/"
      "mail-config:/tmp/docker-mailserver/"
      "/var/lib/caddy/.local/share/caddy/certificates/acme.zerossl.com-v2-dv90/wildcard_.hailsatan.eu:/srv/tls/meow" # it hates this
    ];
    environment = {
      TZ = "Europe/Berlin";
      SPOOF_PROTECTION = "1";
      LOG_LEVEL = "info";
      ENABLE_CLAMAV = "0";
      ENABLE_FAIL2BAN = "0";
      SSL_TYPE = "manual";
      SSL_CERT_PATH = "/srv/tls/meow/wildcard_.hailsatan.eu.crt";
      SSL_KEY_PATH = "/srv/tls/meow/wildcard_.hailsatan.eu.key";
    };
  };
}
