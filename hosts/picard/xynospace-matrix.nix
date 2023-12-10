{ config, pkgs, lib, ... }:
let
  fqdn = "matrix.xyno.space";
  serverName = "xyno.space";
  localAddress = "192.168.100.11";
  hostAddress = "192.168.100.10";
  stateVer = config.system.stateVersion;
in
{
  ragon.agenix.secrets."matrixSecrets" = { owner = "matrix-synapse"; };
  services.postgresql.enable = true;
  services.postgresql.initialScript = lib.mkForce (pkgs.writeText "synapse-init.sql" ''
    CREATE ROLE "matrix-synapse" WITH LOGIN PASSWORD 'synapse';
    CREATE DATABASE "matrix-synapse" WITH OWNER "matrix-synapse-xynospace"
      TEMPLATE template0
      LC_COLLATE = "C"
      LC_CTYPE = "C";
    CREATE ROLE "matrix-synapse-xynospace" WITH LOGIN PASSWORD 'synapse';
    CREATE DATABASE "matrix-synapse-xynospace" WITH OWNER "matrix-synapse-xynospace"
      TEMPLATE template0
      LC_COLLATE = "C"
      LC_CTYPE = "C";
  '');
  networking.nat.enable = true;
  networking.nat.internalInterfaces = [ "ve-+" ];
  networking.nat.externalInterface = "ens3";
  networking.firewall.trustedInterfaces = [ "ve-+" ];

  users.users.slidingsync = { isSystemUser = true; group = "slidingsync"; uid = 990; };
  users.groups.slidingsync = { gid = 988; };
  # virtualisation.oci-containers.containers."matrix-sliding-sync" = {
  #   image = "ghcr.io/matrix-org/sliding-sync:latest";
  #   ports = [ "127.0.0.1:8009:8008" ];
  #   user = "${toString config.users.users.slidingsync.uid}:${toString config.users.groups.slidingsync.gid}";
  #   volumes = [
  #     "/run/postgresql:/run/postgresql"
  #   ];
  #   environmentFiles = [ config.age.secrets.picardSlidingSyncSecret.path ];
  #   environment = {
  #     SYNCV3_SERVER = "https://${fqdn}";
  #     SYNCV3_BINDADDR = ":8008";
  #     SYNCV3_DB = "host=/run/postgresql user=slidingsync dbname=slidingsync password=slidingsync";
  #   };
  # };
  services.postgresql = {
    ensureDatabases = [ "slidingsync" ];
    ensureUsers = [
      {
        name = "slidingsync";
        ensureDBOwnership = true;
      }
    ];
  };
  containers.xynospace-matrix = let ms = config.age.secrets.matrixSecrets.path; in {
    config = { config, pkgs, ... }: {
      system.stateVersion = stateVer;
      networking.firewall.allowedTCPPorts = [ 8008 ];
      services.matrix-synapse = {
        enable = true;
        settings.server_name = serverName;
        extraConfigFiles = [ "/host${ms}" ];
        settings.database.args.user = "matrix-synapse-xynospace";
        settings.database.name = "psycopg2";
        settings.database.args.database = "matrix-synapse-xynospace";
        settings.database.args.host = hostAddress;
        settings.database.args.password = "synapse";
        settings.listeners = [
          {
            port = 8008;
            bind_addresses = [ localAddress ];
            type = "http";
            tls = false;
            x_forwarded = true;
            resources = [
              {
                names = [ "client" "federation" ];
                compress = false;
              }
            ];
          }
        ];
      };
    };
    inherit localAddress hostAddress;
    privateNetwork = true;
    autoStart = true;

    bindMounts = {
      "/host/run" = { hostPath = "/run"; isReadOnly = true; };
      "/run/agenix.d" = { hostPath = "/run/agenix.d"; isReadOnly = true; };
    };

  };
  services.nginx.virtualHosts = {
    "${serverName}" = {
      forceSSL = true;

      locations."= /.well-known/matrix/server".extraConfig =
        let
          # use 443 instead of the default 8448 port to unite
          # the client-server and server-server port for simplicity
          server = { "m.server" = "${fqdn}:443"; };
        in
        ''
          add_header Content-Type application/json;
          return 200 '${builtins.toJSON server}';
        '';
      locations."= /.well-known/matrix/client".extraConfig =
        let
          client = {
            "m.homeserver" = { "base_url" = "https://${fqdn}"; };
            "m.identity_server" = { "base_url" = "https://vector.im"; };
            "org.matrix.msc3575.proxy" = { "url" = "https://slidingsync.ragon.xyz"; };
          };
          # ACAO required to allow element-web on any URL to request this json file
        in
        ''
          add_header Content-Type application/json;
          add_header Access-Control-Allow-Origin *;
          return 200 '${builtins.toJSON client}';
        '';
    };
    # Reverse proxy for Matrix client-server and server-server communication
    "${fqdn}" = {
      forceSSL = true;
      enableACME = true;

      # Or do a redirect instead of the 404, or whatever is appropriate for you.
      # But do not put a Matrix Web client here! See the Element web section below.
      locations."/".extraConfig = ''
        return 404;
      '';

      # forward all Matrix API calls to the synapse Matrix homeserver
      locations."/_matrix" = {
        proxyPass = "http://${localAddress}:8008"; # without a trailing /
      };
      locations."/notifications" = {
        proxyPass = "http://${localAddress}:8008"; # without a trailing /
      };
      locations."/_synapse/client" = {
        proxyPass = "http://${localAddress}:8008"; # without a trailing /
      };
      locations."/health" = {
        proxyPass = "http://${localAddress}:8008"; # without a trailing /
      };
    };
  };
  ragon.persist.extraDirectories = [
    "/var/lib/nixos-containers"
  ];
  services.postgresql.authentication = ''
    host all all ${localAddress}/32 md5
  '';
  services.postgresql.settings.listen_addresses = lib.mkForce "localhost,${hostAddress}";

}
