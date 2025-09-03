{
  config,
  pkgs,
  lib,
  ...
}:
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
  imports = [
    ./authentik.nix
    ./part-db.nix
  ];
  networking.firewall.interfaces."podman+".allowedUDPPorts = [ 53 ];
  networking.firewall.interfaces."podman+".allowedTCPPorts = [
    12300
    3001
  ];
  fileSystems."/var/lib/containers" = {
    device = "spool/safe/containers";
    fsType = "zfs";
  };
  # plex
  # networking.firewall = {
  #   allowedTCPPorts = [ 32400 3005 8324 32469 ];
  #   allowedUDPPorts = [ 1900 5353 32410 32412 32413 32414 ];
  # };
  # virtualisation.oci-containers.containers.plex = {
  #   image = "docker.io/plexinc/pms-docker";
  #   extraOptions = [ "--network=host" ];
  #   environment = {
  #     TZ = "Europe/Berlin";
  #     PLEX_UID = "1000";
  #     PLEX_GID = "100";
  #   };

  #   volumes = [
  #     "/data/media:/data/media"
  #     "plex-transcode:/transcode"
  #     "plex-db:/config"
  #   ];
  # };
  # postgres
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  ragon.agenix.secrets.ds9PostgresEnv = { };
  systemd.services."podman-db-network" = {
    script = ''
      ${pkgs.podman}/bin/podman network exists db-net || ${pkgs.podman}/bin/podman network create db-net --internal --ipv6
    '';
  };
  virtualisation.oci-containers.containers.postgres = {
    image = "docker.io/tensorchord/pgvecto-rs:pg16-v0.2.1";
    extraOptions = [
      "--network=db-net"
      "--network=podman"
      "--health-cmd"
      "pg_isready -U postgres"
    ];
    # dependsOn = [ "db-network" ];
    environment = {
      POSTGRES_INITDB_ARGS = "--data-checksums";
    };
    environmentFiles = [
      config.age.secrets.ds9PostgresEnv.path
    ];
    ports = [ "5432:5432"];
    volumes = [
      "${postgres-multi-db}:/docker-entrypoint-initdb.d/create-multiple-postgresql-databases.sh"
      "postgres:/var/lib/postgresql/data"
    ];
  };
  # immich
  ragon.agenix.secrets.ds9ImmichEnv = { };
  # systemd.services."podman-immich-network" = {
  #   script = ''
  #     echo "Creating immich network"
  #     ${pkgs.podman}/bin/podman network exists immich-net || ${pkgs.podman}/bin/podman network create immich-net --internal --ipv6
  #     echo "Created immich network"
  #   '';
  # };
  virtualisation.oci-containers.containers.immich-redis = {
    image = "docker.io/valkey/valkey:7.2.6-alpine";
    environment.TZ = "Europe/Berlin";
    extraOptions = [
      "--health-cmd"
      "valkey-cli ping || exit 1"
      "--network=immich-net"
    ];
    environmentFiles = [
      config.age.secrets.ds9ImmichEnv.path
    ];
    # dependsOn = [ "immich-network" ];
  };
  virtualisation.oci-containers.containers.immich-server = {
    user = "1000:100";
    image = "ghcr.io/immich-app/immich-server:release";
    extraOptions = [
      "--network=podman"
      "--network=immich-net"
      "--network=db-net"
    ];
    dependsOn = [
      # "immich-network"
      "immich-redis"
      "postgres"
    ];
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
    extraOptions = [
      "--network=immich-net"
      "--network=db-net"
      "--network=podman"
    ];
    dependsOn = [
      # "immich-network"
      "immich-redis"
      "postgres"
    ];
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
  # virtualisation.oci-containers.containers.lms = {
  #   # don't tell mom
  #   # user = "1000:100";
  #   image = "epoupon/lms:latest";
  #   cmd = [ "/lms.conf" ];
  #   extraOptions = [ "--network=podman" ];
  #   volumes =
  #     let
  #       lmsConfig = pkgs.writeText "lms-config" ''
  #         original-ip-header = "X-Forwarded-For";
  #         behind-reverse-proxy = true;
  #         trusted-proxies =
  #         (
  #         	"10.88.0.1"
  #         );
  #         authentication-backend = "http-headers";
  #         http-headers-login-field = "X-Webauth-User";
  #       '';
  #     in
  #     [
  #       "lightweight-music-server-data:/var/lms:rw"
  #       "${lmsConfig}:/lms.conf"
  #       "/data/media/beets/music:/music:ro"
  #     ];
  #   environment = { };
  # };

  # changedetection
  systemd.services."podman-cd-network" = {
    script = ''
      ${pkgs.podman}/bin/podman network exists cd-net || ${pkgs.podman}/bin/podman network create cd-net --internal --ipv6
    '';
  };

  virtualisation.oci-containers.containers.changedetection = {
    image = "dgtlmoon/changedetection.io";
    extraOptions = [
      "--network=podman"
      "--network=cd-net"
    ];
    volumes = [
      "changedetection-data:/datastore"
    ];
  };

  networking.firewall.interfaces."podman0".allowedTCPPorts = [ 9090 ];
  virtualisation.oci-containers.containers.grafana = {
    image = "grafana/grafana-oss:latest";
    extraOptions = [
      "--network=podman"
      "--network=db-net"
    ];
    volumes =
      let
        ini = pkgs.writeText "grafana.ini" ''
          [users]
          allow_sign_up = false
          auto_assign_org = true
          auto_assign_org_role = Viewer

          [auth.proxy]
          enabled = true
          headers = Name:X-Authentik-Username Email:X-Authentik-Email Role:X-Grafana-Role
          header_name = X-Authentik-Username
          header_property = username
          auto_sign_up = true
        '';
      in
      [
        "grafana-data:/var/lib/grafana"
        "${ini}:/etc/grafana/grafana.ini"

      ];
    environment = {
      GF_SERVER_ROOT_URL = "https://grafana.hailsatan.eu/";
      GF_INSTALL_PLUGINS = "";
      GF_FEATURE_TOGGLES_ENABLE = "featureToggleAdminPage, regressionTransformation";
      GF_FEATURE_MANAGEMENT_ALLOW_EDITING = "true";
    };
  };
  virtualisation.oci-containers.containers.node-red = {
    image = "nodered/node-red:latest";
    extraOptions = [
      "--network=podman"
      "--network=db-net"
    ];
    volumes = [
      "nodered-data:/data"
    ];
  };
  virtualisation.oci-containers.containers.jellyfin = {
    image = "jellyfin/jellyfin:latest";
    user = "1000:100";
    extraOptions = [
      "--network=podman"
      "--mount"
      "type=bind,source=/data/media,destination=/media,ro=true,relabel=private"
      "-p"
      "127.0.0.1:8096:8096"
    ];
    volumes = [
      "jellyfin-config:/config"
      "jellyfin-cache:/cache"
    ];
  };
  # archivebox
  systemd.services."podman-archivebox-network" = {
    script = ''
      ${pkgs.podman}/bin/podman network create archivebox-net --internal --ipv6 --ignore
    '';
  };
  virtualisation.oci-containers.containers.archivebox = {
    image = "archivebox/archivebox:dev";
    environment = {
      ALLOWED_HOSTS = "*"; # set this to the hostname(s) you're going to serve the site from!
      CSRF_TRUSTED_ORIGINS = "https://archive.hailsatan.eu"; # you MUST set this to the server's URL for admin login and the REST API to work
      REVERSE_PROXY_USER_HEADER = "X-Authentik-Username";
      REVERSE_PROXY_WHITELIST = "10.88.0.1/32";
      PUBLIC_INDEX = "False"; # set to False to prevent anonymous users from viewing snapshot list
      PUBLIC_SNAPSHOTS = "False"; # set to False to prevent anonymous users from viewing snapshot content
      PUBLIC_ADD_VIEW = "False"; # set to True to allow anonymous users to submit new URLs to archive
      SEARCH_BACKEND_ENGINE = "sonic"; # tells ArchiveBox to use sonic container below for fast full-text search
      SEARCH_BACKEND_HOST_NAME = "archivebox_sonic";
      SEARCH_BACKEND_PASSWORD = "SomeSecretPassword";
    };
    extraOptions = [
      "--network=archivebox-net"
      "--network=podman"
    ];
    volumes = [
      "/data/media/archivebox:/data"
    ];
  };
  virtualisation.oci-containers.containers.archivebox_scheduler = {
    image = "archivebox/archivebox:latest";
    cmd = [
      "schedule"
      "--foreground"
      "--update"
      "--every=day"
    ];
    environment = {
      TIMEOUT = "120";
      ALLOWED_HOSTS = "*"; # set this to the hostname(s) you're going to serve the site from!
      CSRF_TRUSTED_ORIGINS = "https://archive.hailsatan.eu"; # you MUST set this to the server's URL for admin login and the REST API to work
      PUBLIC_INDEX = "True"; # set to False to prevent anonymous users from viewing snapshot list
      PUBLIC_SNAPSHOTS = "True"; # set to False to prevent anonymous users from viewing snapshot content
      PUBLIC_ADD_VIEW = "False"; # set to True to allow anonymous users to submit new URLs to archive
      SEARCH_BACKEND_ENGINE = "sonic"; # tells ArchiveBox to use sonic container below for fast full-text search
      SEARCH_BACKEND_HOST_NAME = "archivebox_sonic";
      SEARCH_BACKEND_PASSWORD = "SomeSecretPassword";
    };
    extraOptions = [
      "--network=archivebox-net"
      "--network=podman"
    ];
    volumes = [
      "/data/media/archivebox:/data"
    ];
  };
  virtualisation.oci-containers.containers.archivebox_sonic = {
    image = "archivebox/sonic:latest";
    environment = {
      SEARCH_BACKEND_PASSWORD = "SomeSecretPassword";
    };
    extraOptions = [ "--network=archivebox-net" ];
    volumes = [
      "archivebox-sonic:/data"
    ];
  };
  # printer
  virtualisation.oci-containers.containers.labello = {
    image = "telegnom/labello:latest";
    environment = {
      LAB_PRINTER_DEVICE = "tcp://BRN008077572A96.lan:9100";
      # LABELLO_DOWNLOAD_FONT = "yes";
    };
    extraOptions = [ "--network=podman" ];
    volumes =
      let
        fonts = pkgs.runCommandNoCC "labello-fonts" {} ''
            mkdir $out
            cp ${pkgs.roboto}/share/fonts/truetype/* $out
            cp ${pkgs.roboto-mono}/share/fonts/truetype/* $out
          '';
      in
      [
        "${fonts}:/opt/labello/fonts"
        # "/nix/store:/nix/store"
      ];
  };
  virtualisation.oci-containers.containers.copyparty = {
    image = "docker.io/copyparty/ac:latest";
    extraOptions = [ "--network=podman" ];
    ports = [ ];
    volumes =
      let
        copypartyCfg = ''
          [global]
            xff-src: 10.88.0.1/24
            idp-h-usr: X-Authentik-Username
            idp-h-grp: X-Copyparty-Group
            e2dsa  # enable file indexing and filesystem scanning
            e2ts   # enable multimedia indexing
            ansi   # enable colors in log messages
            re-maxage: 3600   # rescan every something
            hist: /data/media/copyparty/cache
            name: the gayest storage in the west
            no-robots
            shr: /shr
            shr-adm: @admin
          [/]
            /data/media/copyparty/srv
            accs:
              A: @admin
              r: *
          [/dump]
            /data/media/copyparty/srv/dump
            flags:
              dedup
            accs:
              A: @admin
              w: *
          [/pub]
            /data/media/copyparty/srv/pub
            flags:
              dedup
            accs:
              A: @admin
              rw: *
          [/tv]
            /data/media/tv
            flags:
              hist: /data/media/copyparty/hist/tv
            accs:
              r: *
          [/movies]
            /data/media/movies
            flags:
              hist: /data/media/copyparty/hist/movies
            accs:
              r: *
          [/books]
            /data/media/books
            flags:
              hist: /data/media/copyparty/hist/books
            accs:
              r: *
          [/audiobooks]
            /data/media/audiobooks
            flags:
              hist: /data/media/copyparty/hist/audiobooks
            accs:
              r: *
          [/music]
            /data/media/music
            flags:
              hist: /data/media/copyparty/hist/music
            accs:
              r: *
          [/games]
            /data/media/games
            flags:
              hist: /data/media/copyparty/hist/games
            accs:
              r: *
        '';
        cpp = pkgs.writeText "copyparty.conf" copypartyCfg;
      in
      [

        "/data/media/tv:/data/media/tv:ro"
        "/data/media/movies:/data/media/movies:ro"
        "/data/media/audiobooks:/data/media/audiobooks:ro"
        "/data/media/books:/data/media/books:ro"
        "/data/media/games:/data/media/games:ro"
        "/data/media/beets:/data/media/music:ro"
        "/data/media/copyparty:/data/media/copyparty"
        "/data/media/copyparty/cfg:/cfg"
        "${cpp}:/cfg/copyparty.conf"
      ];
  };

}
