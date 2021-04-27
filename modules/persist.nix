{ config, lib, pkgs, inputs, ... }:
let
  cfg = config.ragon.persist;
  ragon = config.ragon;
in
{
  options.ragon.persist.enable = lib.mkEnableOption "Enables persistence"; # TODO this needs to be fixed up fully
  config = lib.mkIf cfg.enable {

    environment.etc."smb-secrets" = {
      text = secrets.smbSecret;
      mode = "0400";
    };

    environment.persistence."/persistent" = {
      directories = [
        "/etc/nixos"
        "/etc/NetworkManager/system-connections"
        "/root/.ssh"
      ];
      files = [
        "/etc/machine-id"
        "/etc/ssh/ssh_host_rsa_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
      ];
    };
  
  };

}
