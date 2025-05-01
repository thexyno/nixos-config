{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
{
  imports = [
    inputs.quadlet-nix.nixosModules.quadlet
  ];
  ragon.agenix.secrets.ds9AuthentikEnv = { };
  ragon.agenix.secrets.ds9AuthentikLdapEnv = { };
  virtualisation.quadlet = {
    containers = {
      authentik-server.containerConfig.image = "ghcr.io/goauthentik/server:2025.2.3";

      authentik-server.containerConfig.exec = "server";
      authentik-server.containerConfig.networks = [
        "podman"
        "db-net"
        "authentik-net"
      ];
      authentik-server.containerConfig.volumes = [
        "authentik-media:/media"
        "authentik-certs:/certs"
      ];
      authentik-server.containerConfig.environments = {
        AUTHENTIK_REDIS__HOST = "authentik-redis";
        AUTHENTIK_POSTGRESQL__HOST = "postgres";
        AUTHENTIK_POSTGRESQL__USER = "authentik";
        AUTHENTIK_POSTGRESQL__NAME = "authentik";

      };
      authentik-server.serviceConfig.TimeoutStartSec = "60";
      authentik-server.containerConfig.environmentFiles = [
        config.age.secrets.ds9AuthentikEnv.path
      ];
      authentik-worker.containerConfig.image = "ghcr.io/goauthentik/server:2025.2.3";

      authentik-worker.containerConfig.exec = "worker";
      authentik-worker.containerConfig.networks = [
        "podman"
        "db-net"
        "authentik-net"
      ];
      authentik-worker.containerConfig.volumes = [
        "authentik-media:/media"
        "authentik-certs:/certs"
      ];
      authentik-worker.containerConfig.environments = {
        AUTHENTIK_REDIS__HOST = "authentik-redis";
        AUTHENTIK_POSTGRESQL__HOST = "postgres";
        AUTHENTIK_POSTGRESQL__USER = "authentik";
        AUTHENTIK_POSTGRESQL__NAME = "authentik";

      };
      authentik-worker.containerConfig.environmentFiles = [
        config.age.secrets.ds9AuthentikEnv.path
      ];
      authentik-worker.serviceConfig.TimeoutStartSec = "60";
      authentik-ldap.containerConfig.image = "ghcr.io/goauthentik/ldap:2025.2.3";

      authentik-ldap.containerConfig.networks = [
        "podman"
        "authentik-net"
      ];
      authentik-ldap.containerConfig.environments = {
        AUTHENTIK_HOST = "http://authentik-server:9000";
        AUTHENTIK_INSECURE = "true";
      };
      authentik-ldap.containerConfig.environmentFiles = [
        config.age.secrets.ds9AuthentikLdapEnv.path
      ];
      authentik-ldap.serviceConfig.TimeoutStartSec = "60";
      authentik-redis.containerConfig.image = "docker.io/library/redis:alpine";
      authentik-redis.containerConfig.networks = [
        "authentik-net"

      ];
      authentik-redis.containerConfig.volumes = [ "authentik-redis:/data" ];
      authentik-redis.serviceConfig.TimeoutStartSec = "60";
    };
    networks = {
      authentik.networkConfig.ipv6 = true;
      authentik.networkConfig.name = "authentik-net";
      authentik.networkConfig.internal = true;
    };
  };
}
