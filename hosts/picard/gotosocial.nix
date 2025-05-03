{ pkgs, config, ... }: {
  virtualisation.oci-containers.containers."gts" = {
    image = "superseriousbusiness/gotosocial:latest";
    environment = {
      GTS_HOST = "l621.net";
      GTS_DB_TYPE = "sqlite";
      GTS_DB_ADDRESS = "/gotosocial/storage/sqlite.db";
      GTS_LETSENCRYPT_ENABLED = "false";
      GTS_WAZERO_COMPILATION_CACHE = "/gotosocial/.cache";
      GTS_TRUSTED_PROXIES = "10.88.0.0/16";
      TZ = "Europe/Berlin";
    };
    ports = [
      "127.0.0.1:8186:8080"
    ];
    volumes = [
      "/var/lib/gotosocial:/gotosocial/storage"
    ];
  };
  ragon.persist.extraDirectories = ["/var/lib/gotosocial"];
  
}
