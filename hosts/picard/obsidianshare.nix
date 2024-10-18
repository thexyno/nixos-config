{ pkgs, config, ... }: {
  ragon.agenix.secrets.picardSharenoteEnv = { };
  virtualisation.oci-containers.containers."sharenote" = {
    image = "ghcr.io/thexyno/sharenote-py:latest";
    environmentFiles = [
      config.age.secrets.picardSharenoteEnv.path
    ];
    ports = [
      "127.0.0.1:8086:8086"
    ];
    volumes = [
      "/var/lib/sharenote:/sharenote-py/static"
    ];
  };
  ragon.persist.extraDirectories = ["/var/lib/sharenote"];
  
}
