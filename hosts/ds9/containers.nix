{ config, pkgs, lib, ... }:
let
  postgres-multi-db = pkgs.writeText "postgres-multiple-db.sh" ''
    #!/usr/bin/env bash
    set -eu

    if [ -n "$POSTGRES_MULTIPLE_DATABASES" ]; then
      echo "Multiple database creation requested: $POSTGRES_MULTIPLE_DATABASES"
      (
        for db in $(echo $POSTGRES_MULTIPLE_DATABASES | tr ',' ' '); do
          echo "CREATE DATABASE $db;"
        done
        for user in $(echo $POSTGRES_MULTIPLE_DATABASES_USERS | tr ',' ' '); do
          while IFS=":" read -r usr pw
          do
          echo "CREATE USER $usr PASSWORD '$pw';"
          echo "GRANT ALL PRIVILEGES ON DATABASE \"$usr\" TO $usr;"
          done <(echo $user)
        done
      ) | psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER"
    fi
  '';
in
{
  networking.firewall.interfaces."podman+".allowedUDPPorts = [ 53 ];
  networking.firewall.interfaces."podman+".allowedTCPPorts = [ 12300 3001 ];
  fileSystems."/var/lib/containers" = {
    device = "spool/safe/containers";
    fsType = "zfs";
  };
  # plex
  networking.firewall = {
    allowedTCPPorts = [ 32400 3005 8324 32469 ];
    allowedUDPPorts = [ 1900 5353 32410 32412 32413 32414 ];
  };
  virtualisation.oci-containers.containers.plex = {
    image = "docker.io/plexinc/pms-docker";
    extraOptions = [ "--network=host" ];
    environment = {
      TZ = "Europe/Berlin";
      PLEX_UID = "1000";
      PLEX_GID = "100";
    };

    volumes = [
      "/data/media:/data/media"
      "plex-transcode:/transcode"
      "plex-db:/config"
    ];
  };
  # postgres
  ragon.agenix.secrets.ds9PostgresEnv = { };
  systemd.services."podman-db-network" = {
    script = ''
      ${pkgs.podman}/bin/podman network exists db-net || ${pkgs.podman}/bin/podman network create db-net --internal --ipv6
    '';
  };
  virtualisation.oci-containers.containers.postgres = {
    image = "docker.io/tensorchord/pgvecto-rs:pg16-v0.2.1";
    extraOptions = [ "--network=db-net" "--health-cmd" "pg_isready -U postgres" ];
    dependsOn = [ "db-network" ];
    environment = {
      POSTGRES_INITDB_ARGS = "--data-checksums";
    };
    environmentFiles = [
      config.age.secrets.ds9PostgresEnv.path
    ];
    volumes = [
      "${postgres-multi-db}:/docker-entrypoint-initdb.d/create-multiple-postgresql-databases.sh"
      "postgres:/var/lib/postgresql/data"
    ];
  };
  # immich
  ragon.agenix.secrets.ds9ImmichEnv = { };
  systemd.services."podman-immich-network" = {
    script = ''
      echo "Creating immich network"
      ${pkgs.podman}/bin/podman network exists immich-net || ${pkgs.podman}/bin/podman network create immich-net --internal --ipv6
      echo "Created immich network"
    '';
  };
  virtualisation.oci-containers.containers.immich-redis = {
    image = "docker.io/valkey/valkey:7.2.6-alpine";
    environment.TZ = "Europe/Berlin";
    extraOptions = [ "--health-cmd" "valkey-cli ping || exit 1" "--network=immich-net" ];
    environmentFiles = [
      config.age.secrets.ds9ImmichEnv.path
    ];
    dependsOn = [ "immich-network" ];
  };
  virtualisation.oci-containers.containers.immich-server = {
    user = "1000:100";
    image = "ghcr.io/immich-app/immich-server:release";
    extraOptions = [ "--network=podman" "--network=immich-net" "--network=db-net" ];
    dependsOn = [ "immich-network" "immich-redis" "postgres" ];
    ports = [ "8765:3001" ];
    volumes = [
      "/data/immich:/usr/src/app/upload"
    ];
    environment = {
      IMICH_HOST = "0.0.0.0";
      DB_HOSTNAME = "postgres";
      REDIS_HOSTNAME = "immich-redis";
      TZ = "Europe/Berlin";
    };
    environmentFiles = [
      config.age.secrets.ds9ImmichEnv.path
    ];
  };
  virtualisation.oci-containers.containers.immich-machine-learning = {
    user = "1000:100";
    image = "ghcr.io/immich-app/immich-machine-learning:release";
    extraOptions = [ "--network=immich-net" "--network=db-net" "--network=podman" ];
    dependsOn = [ "immich-network" "immich-redis" "postgres" ];
    volumes = [
      "immich-model-cache:/cache"
    ];
    environment = {
      DB_HOSTNAME = "postgres";
      REDIS_HOSTNAME = "immich-redis";
      TZ = "Europe/Berlin";
    };
    environmentFiles = [
      config.age.secrets.ds9ImmichEnv.path
    ];
  };
  # navidrome
  virtualisation.oci-containers.containers.navidrome = {
    user = "1000:100";
    image = "deluan/navidrome:latest";
    extraOptions = [ "--network=podman" ];
    volumes = [
      "navidrome-data:/data"
      "/data/media/music:/music:ro"
    ];
    environment = {
      ND_SCANSCHEDULE = "1h";
      ND_SESSIONTIMEOUT = "900h";
      ND_BASEURL = "https://nd.hailsatan.eu";
    };
  };

}
