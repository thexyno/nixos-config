{ config, lib, pkgs, inputs, ... }:
let
  cfg = config.ragon.persist;
in
{
  options.ragon.persist.enable = lib.mkEnableOption "Enables persistence"; # TODO this needs to be fixed up fully
  options.ragon.persist.extraFiles = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
  };
  options.ragon.persist.extraDirectories = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
  };
  config = lib.mkIf cfg.enable {

    environment.persistence."/persistent" = {
      directories = [
        "/etc/nixos"
        "/etc/NetworkManager/system-connections"
        "/root/.ssh"
      ] ++ cfg.extraDirectories;
      files = [
        "/etc/machine-id"
        "/etc/ssh/ssh_host_rsa_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
      ] ++ cfg.extraFiles;
    };
  
  };

}
