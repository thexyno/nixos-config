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
  ragon.agenix.enable = false;
  environment.systemPackages = [
    (pkgs.writeScriptBin "generateSystem1" ''
      #!${pkgs.bash}/bin/bash
      set -x
      if [ -z $1 ]; then
        echo please set a device
        exit 1
      fi
      if [ -z $2 ]; then
        echo please set a swap size
        exit 1
      fi
      dev=/dev/$1
      parted $dev -- mklabel gpt
      parted $dev -- mkpart primary 512M -$2
      parted $dev -- mkpart primary linux-swap -$2 100%
      parted $dev -- mkpart ESP fat32 1M 512M
      mkfs.fat -F32 -n boot ''${dev}3
      mount -t tmpfs tmpfs /mnt
      mkdir -p /mnt/{boot,nix,persistent,etc/ssh,var/{lib,log}}
      echo "now create your main file system (on ''${dev}1), mount /mnt/nix and /mnt/persistent and then run generateSystem2"
    '')
    (pkgs.writeScriptBin "generateSystem2" ''
      #!${pkgs.bash}/bin/bash
      set -x
      if [ -z $1 ]; then
        echo please set a device
        exit 1
      fi
      dev=/dev/$1
      
      mkdir -p /mnt/persistent/{etc/ssh,var/{lib,log},srv}
      mount -o bind /mnt/persistent/var/log /mnt/var/log
      ssh-keygen -t ed25519 -f /mnt/persistent/etc/ssh/ssh_host_ed25519_key
      ssh-keygen -t rsa -f /mnt/persistent/etc/ssh/ssh_host_rsa_key
      echo now add this pubkey to your agenix please
      cat /mnt/persistent/etc/ssh/ssh_host_ed25519_key.pub

      echo "then you can install your system with 'nixos-install --root /mnt --no-root-passwd --flake github:ragon000/nixos-config#<hostname>'"
    '')
  ];

} 
