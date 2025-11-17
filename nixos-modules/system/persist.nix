{ config, lib, pkgs, inputs, ... }:
let
  cfg = config.ragon.persist;
in
{
  options.ragon.persist.enable = lib.mkEnableOption "Enables persistence";
  options.ragon.persist.extraFiles = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
  };
  options.ragon.persist.extraDirectories = lib.mkOption {
    type = lib.types.listOf lib.types.anything;
    default = [ ];
  };
  options.ragon.persist.baseDir = lib.mkOption {
    type = lib.types.str;
    default = "/persistent";
  };
  config = lib.mkIf cfg.enable {

    environment.persistence.${cfg.baseDir} = {
      directories = [
        "/etc/nixos"
        "/etc/NetworkManager/system-connections"
        "/var/lib/nixos"
        "/root/.ssh"
      ] ++ (lib.unique cfg.extraDirectories);
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
