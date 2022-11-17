{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.services.ssh;
  pubkeys = import ../../data/pubkeys.nix;
in
{
  options.ragon.services.ssh.enable = lib.mkEnableOption "Enables sshd";
  config = lib.mkIf cfg.enable {
    services.openssh.permitRootLogin = "without-password";
    services.openssh.enable = true;
    services.openssh.passwordAuthentication = false;
    users.users.root.openssh.authorizedKeys.keys = pubkeys.ragon.user;
  };
}
