
{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.services.ssh;
in
{
  options.ragon.services.ssh.enable = lib.mkEnableOption "Enables sshd"
  config = lib.mkIf cfg.enable {
    services.openssh.permitRootLogin = "no";
    services.openssh.enable = true;
    services.openssh.passwordAuthentication = false;
  }
}
