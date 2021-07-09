{ config, pkgs, modulesPath, ...}:
{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    "${modulesPath}/installer/cd-dvd/channel.nix"
  ];
  fileSystems."/".device = "tmpfs";
  users.users.root.password = "123456";
  services.sshd.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMvexOT9tnx2LfAE/OwfixfNc/esNAjZ+GDfLpY2iABk philipp@philipp-archPC"
  ];
  networking.firewall.enable = false;

} 
