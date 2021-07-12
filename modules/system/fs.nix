{ config, lib, pkgs, ... }:
with lib;
with lib.my;
let
  cfg = config.ragon.system.fs;
  nix = cfg.nix;
  varlog = cfg.varlog;
  persistent = cfg.persistent;
  persistentSnapshot = cfg.persistentSnapshot;
  arcSize = cfg.arcSize;
  hostName = config.networking.hostName;
in
{
  options.ragon.system.fs = {
    enable = lib.mkEnableOption "Enables ragons fs stuff, (tmpfs,zfs,backups,...)";
    mediadata = mkBoolOpt false;
    swap = mkBoolOpt true;
    persistentSnapshot = mkBoolOpt true;
    nix = lib.mkOption {
      type = lib.types.str;
      default = "pool/nix";
    };
    varlog = lib.mkOption {
      type = lib.types.str;
      default = "pool/varlog";
    };
    persistent = lib.mkOption {
      type = lib.types.str;
      default = "pool/persist";
    };
    arcSize = lib.mkOption {
      type = lib.types.int;
      default = 2;
      description = "Sets the ZFS Arc Size (in GB)";
    };
  };
  config = lib.mkIf cfg.enable {
    services.zfs.autoScrub.enable = true;
    services.sanoid = {
      enable = mkDefault persistentSnapshot;
    } // (if persistentSnapshot then { datasets."${persistent}" = { }; } else {});
    services.syncoid = {
      user = "root";
      group = "root";
      sshKey = /persistent/root/.ssh/id_rsa;
      enable = mkDefault true;
      commonArgs = [
      ];
      commands."${persistent}" = {
        target = "root@ds9:rpool/content/local/backups/${hostName}";
        recvOptions = "x encryption";
      };
    };
    boot.kernelParams = [ "zfs.zfs_arc_max=${toString (arcSize * 1024 * 1024 * 1024)}" ];
    fileSystems."/" =
      {
        device = "none";
        fsType = "tmpfs";
        options = [ "size=8G" "defaults" "mode=755" ];
      };
    fileSystems."/nix" =
      {
        device = "${nix}";
        fsType = "zfs";
        neededForBoot = true;
      };

    fileSystems."/persistent" =
      {
        device = "${persistent}";
        fsType = "zfs";
        neededForBoot = true;
      };

    fileSystems."/var/log" =
      {
        device = "${varlog}";
        fsType = "zfs";
      };

    fileSystems."/boot" =
      {
        device = "/dev/disk/by-label/boot";
        fsType = "vfat";
        options = [ "noauto" "x-systemd.automount" ];
      };
    fileSystems."/media/data" =
      lib.mkIf
        (config.ragon.hardware.laptop.enable == false && cfg.mediadata)
        {
          device = "//10.0.0.2/data";
          fsType = "cifs";
          options =
            let
              # this line prevents hanging on network split
              automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
            in
            [ "${automount_opts},credentials=/run/secrets/smb,uid=1000,gid=1" ];

        };

    swapDevices = mkIf cfg.swap [
        { device = "/dev/zvol/pool/swap"; }
      ] ;

  };
}
