{ config, pkgs, lib, ... }: {
  ragon.agenix.secrets."ds9OffsiteBackupSSH" = { };
  ragon.agenix.secrets."ds9SyncoidHealthCheckUrl" = { };
  ragon.agenix.secrets."gatebridgeHostKeys" = { };
  ragon.agenix.secrets."borgmaticEncryptionKey" = { };

  # Backup Target
  users.users.picardbackup = {
    createHome = false;
    group = "users";
    uid = 993;
    home = "/backups/picard";
    shell = "/run/current-system/sw/bin/bash";
    isSystemUser = true;
    openssh.authorizedKeys.keys = [
      ''command="${pkgs.borgbackup}/bin/borg serve --restrict-to-path /backups/picard/",restrict ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHvCF8KGgpF9O8Q7k+JXqZ5eMeEeTaMhCIk/2ZFOzXL0''
    ];
  };

  services.borgmatic = {
    enable = true;
    configurations."ds9-offsite" = {
      source_directories = [ "/backups" "/data" "/persistent" ];
      repositories = [{ label = "gatebridge"; path = "ssh://root@gatebridge/media/backup/ds9"; }];
      exclude_if_present = [ ".nobackup" ];
      #upload_rate_limit = "4000";
      encryption_passcommand = "${pkgs.coreutils}/bin/cat ${config.age.secrets.borgmaticEncryptionKey.path}";
      compression = "auto,zstd,10";
      ssh_command = "ssh -o ClientAliveInterval=10 -o ClientAliveCountMax=30 -o GlobalKnownHostsFile=${config.age.secrets.gatebridgeHostKeys.path} -i ${config.age.secrets.ds9OffsiteBackupSSH.path}";
      before_actions = [ "${pkgs.curl}/bin/curl -fss -m 10 --retry 5 -o /dev/null $(${pkgs.coreutils}/bin/cat ${config.age.secrets.ds9SyncoidHealthCheckUrl.path})/start" ];
      after_actions = [ "${pkgs.curl}/bin/curl -fss -m 10 --retry 5 -o /dev/null $(${pkgs.coreutils}/bin/cat ${config.age.secrets.ds9SyncoidHealthCheckUrl.path})" ];
      on_error = [ "${pkgs.curl}/bin/curl -fss -m 10 --retry 5 -o /dev/null $(${pkgs.coreutils}/bin/cat ${config.age.secrets.ds9SyncoidHealthCheckUrl.path})/fail" ];
      retention = {
        keep_daily = 7;
        keep_weekly = 4;
        keep_monthly = 12;
        keep_yearly = 10;
      };
    };
  };

}
