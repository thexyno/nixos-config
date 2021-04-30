{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.system.fs;
  arcSize = cfg.arcSize;
  hostName = config.networking.hostName;
in
{
  options.ragon.system.fs.enable = lib.mkEnableOption "Enables ragons fs stuff, (tmpfs,zfs,backups,...)";
  options.ragon.system.fs.arcSize = lib.mkOption {
    type = lib.types.integer;
    default = 2;
    description = "Sets the ZFS Arc Size (in GB)";
  };
  config = lib.mkIf cfg.enable {
    services.zfs.autoScrub.enable = true;
    services.sanoid = {
      enable = true;
      datasets."pool/persist" = { };
    };
    services.syncoid = {
      user = "root";
      group = "root";
      sshKey = /persistent/root/.ssh/id_rsa;
      enable = true;
      commonArgs = [
      ];
      commands."pool/persist" = {
        target = "root@pve:data/Backups/${hostName}";
        recvOptions = "x encryption";
      };
    };
    boot.kernelParams = [ "zfs.zfs_arc_max=${arcSize * 1024 * 1024 * 1024}" ];
    fileSystems."/" =
      {
        device = "none";
        fsType = "tmpfs";
        options = [ "size=8G" "defaults" "mode=755" ];
      };
    fileSystems."/nix" =
      {
        device = "pool/nix";
        fsType = "zfs";
      };

    fileSystems."/persistent" =
      {
        device = "pool/persist";
        fsType = "zfs";
        neededForBoot = true;
      };

    fileSystems."/var/log" =
      {
        device = "pool/varlog";
        fsType = "zfs";
      };

    fileSystems."/boot" =
      {
        device = "/dev/disk/by-label/boot";
        fsType = "vfat";
        options = [ "noauto" "x-systemd.automount" ];
      };
  fileSystems."/media/data" = {
    device = "//10.0.0.2/data";
    fsType = "cifs";
    options =
      let
        # this line prevents hanging on network split
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
      in
      [ "${automount_opts},credentials=/run/secrets/smb,uid=1000,gid=1" ];

  };

    swapDevices =
      [{ device = "/dev/zvol/pool/swap"; }];

    };
}
