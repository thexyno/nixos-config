{ config, pkgs, lib, ... }:
{

  users.users.calcom = {
    group = "calcom";
    shell = "${pkgs.bash}/bin/bash";
    uid = 592;
  };
  users.groups.calcom = {
    gid = config.users.users.calcom.uid;
  };
  virtualisation.oci-containers.containers."calcom" = {
    image = "calcom/cal.com:latest";
    ports = [ "127.0.0.1:3469:3000" ];
    user = "${toString config.users.users.calcom.uid}:${toString config.users.groups.calcom.gid}";
    volumes = [
      "/run/postgresql:/run/postgresql"
    ];
    environmentFiles = [ config.age.secrets.picardCalCom.path ];
    environment = {
      DATABASE_URL = "postgresql://calcom:calcom@/run/postgresql";
      NEXT_PUBLIC_WEBAPP_URL = "https://cal.xyno.systems";
      CALCOM_TELEMETRY_DISABLED = 1;
    };
  };
  services.postgresql = {
    ensureDatabases = [ "calcom" ];
    ensureUsers = [
      {
        name = "calcom";
        ensureDBOwnership = true;
      }
    ];
  };
}
