# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ "${modulesPath}/installer/scan/not-detected.nix" ];

  boot.initrd.availableKernelModules = [ "r8169" "ahci" "vfio-pci" "xhci_pci" "ehci_pci" "nvme" "usbhid" "sd_mod" "sr_mod" ];
  boot.kernelModules = [ "kvm-amd" ];
  nix.settings.max-jobs = lib.mkDefault 12;
  powerManagement.cpuFreqGovernor = "performance";

  services.zfs.autoScrub.enable = true;
  ragon.system.fs = {
    enable = true;
    mediadata = false;
    swap = false;
    persistentSnapshot = false;
    nix = "spool/local/nix";
    varlog = "spool/local/journal";
    persistent = "spool/safe/persist";
    arcSize = 8;
  };

  services.sanoid.datasets."rpool/content/safe/data/media" = { };
  services.sanoid.enable = true;

  swapDevices = [{ device = "/dev/disk/by-id/nvme-eui.000000000000000100a075202c247839-part1"; randomEncryption = true; }];
  fileSystems."/boot".device = "/dev/disk/by-uuid/149F-23AA";

  fileSystems."/data" = {
    device = "rpool/content/safe/data";
    fsType = "zfs";
  };
  fileSystems."/data/media" = {
    device = "rpool/content/safe/data/media";
    fsType = "zfs";
  };
  fileSystems."/backups" = {
    device = "rpool/content/local/backups";
    fsType = "zfs";
  };
  fileSystems."/data/media/nzbr" = {
    device = "10.0.1.2:/storage/media";
    fsType = "nfs";
    options = [ "x-systemd.automount" "noauto" ];
  };

}
