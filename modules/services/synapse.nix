{ config, lib, pkgs, ... }:
with lib;
with lib.my;
let
  cfg = config.ragon.services.synapse;
  fqdn = cfg.fqdn;
  serverName = cfg.serverName;
  domain = config.ragon.services.nginx.domain;
in
{
  options.ragon.services.synapse.enable = mkEnableOption "Enables synapse";
  options.ragon.services.synapse.fqdn =
    lib.mkOption {
      type = lib.types.str;
      default = "m.ragon.xyz";
    };
  options.ragon.services.synapse.enableElement = mkBoolOpt true; # TODO fix
  options.ragon.services.synapse.elementFqdn =
    lib.mkOption {
      type = lib.types.str;
      default = "e.ragon.xyz";
    };
  options.ragon.services.synapse.serverName =
    lib.mkOption {
      type = lib.types.str;
      default = "ragon.xyz";
    };
  config = lib.mkIf cfg.enable {
    services.matrix-synapse = {
      enable = true;
      server_name = serverName;
      listeners = [
        {
          port = 8008;
          bind_address = "::1";
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
    services.postgresql = {
      enable = true;
    };
    services.postgresql.initialScript = pkgs.writeText "synapse-init.sql" ''
      CREATE ROLE "matrix-synapse" WITH LOGIN PASSWORD 'synapse';
      CREATE DATABASE "matrix-synapse" WITH OWNER "matrix-synapse"
        TEMPLATE template0
        LC_COLLATE = "C"
        LC_CTYPE = "C";
    '';
    services.nginx.virtualHosts = {
      "${cfg.elementFqdn}" = {
        useACMEHost = "${domain}";
        forceSSL = true;

        root = pkgs.element-web.override {
          conf = {
            default_server_config."m.homeserver" = {
              "base_url" = "https://${fqdn}";
              "server_name" = "${domain}";
            };
            default_theme = "dark";
            jitsi.preferredDomain = "${config.ragon.services.jitsi.domainPrefix}.${domain}";
          }; # TODO make this less shit
        };
      };

      "${cfg.serverName}" = {
        forceSSL = true;
        useACMEHost = "${domain}";
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
              "im.vector.riot.jitsi" = { "preferredDomain" = "jitsi.${domain}"; };
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
        useACMEHost = "${domain}";

        # Or do a redirect instead of the 404, or whatever is appropriate for you.
        # But do not put a Matrix Web client here! See the Element web section below.
        locations."/".extraConfig = ''
          return 404;
        '';

        # forward all Matrix API calls to the synapse Matrix homeserver
        locations."/_matrix" = {
          proxyPass = "http://[::1]:8008"; # without a trailing /
        };
      };


    };

    ragon.persist.extraDirectories = [
      "${config.services.postgresql.dataDir}"
      "${config.services.matrix-synapse.dataDir}"
    ];
  };
}
