{ config, pkgs, modulesPath, ... }:
{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    "${modulesPath}/installer/cd-dvd/channel.nix"
  ];
  fileSystems."/".device = "tmpfs";
  users.users.root.password = "123456";
  services.sshd.enable = true;
  users.users.root.openssh.authorizedKeys.keys = pkgs.pubkeys.ragon.computers;
  networking.firewall.enable = false;

} 
