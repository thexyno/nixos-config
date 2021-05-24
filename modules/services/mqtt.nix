{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.services.mqtt;
  nginx = config.ragon.services.nginx;
in
{
  options.ragon.services.mqtt.enable = lib.mkEnableOption "Enables mosquitto";
  options.ragon.services.mqtt.userName = 
    lib.mkOption {
      type = lib.types.str;
      default = "mqtt";
    };
  options.ragon.services.mqtt.hashedPasswordFile = 
    lib.mkOption {
      description = "Specifies the path to a file containing the hashed password for the MQTT user. To generate hashed password install mosquitto package and use mosquitto_passwd";
      type = lib.types.str;
      default = "/run/secrets/mqttPasswd";
    };
  config = lib.mkIf cfg.enable {
    services.mosquitto = {
      enable = true;
      users."${cfg.userName}".hashedPasswordFile = cfg.hashedPasswordFile;
      checkPasswords = true;
      host = "0.0.0.0";
      ssl = {
        enable = nginx.enable;
        keyfile = "/var/lib/acme/${nginx.domain}/${nginx.domain}.key";
        certfile = "/var/lib/acme/${nginx.domain}/${nginx.domain}.crt";
        cafile = "/var/lib/acme/${nginx.domain}/${nginx.domain}.issuer.crt";
      };

    };
    networking.firewall.allowedTCPPorts = [
      config.services.mosquitto.port
      config.services.mosquitto.ssl.port
    ];
    ragon.persist.extraDirectories = [
      config.services.mosquitto.dataDir
    ];
  };
}
