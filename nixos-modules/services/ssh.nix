{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.services.ssh;
  pubkeys = import ../../data/pubkeys.nix;
in
{
  options.ragon.services.ssh.enable = lib.mkEnableOption "Enables sshd";
  config = lib.mkIf cfg.enable {
    services.openssh.settings.PermitRootLogin = "without-password";
    services.openssh.enable = true;
    services.openssh.settings.PasswordAuthentication = false;
    users.users.root.openssh.authorizedKeys.keys = pubkeys.ragon.user;
  };
}
