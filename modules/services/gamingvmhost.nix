{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.services.gamingvmhost;
  name = cfg.name;
  pciAddrs = cfg.pciAddrs;
  pciIds = cfg.pciIds;
in
{
  options.ragon.services.gamingvmhost = {
    enable = lib.mkEnableOption "Enables vm stuff";
    name = lib.mkOption {
      type = lib.types.str;
      default = "gamingvm";
    };
    pciAddrs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "0000:06:00.0" "0000:06:00.1" ];
    };
    pciIds = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "10de:1b80" "10de:10f0" ];
    };
  };
  config = lib.mkIf cfg.enable {

    programs.dconf.enable = true;
    environment.systemPackages = with pkgs; [
      #      scream-recievers
      scream
      virt-manager
    ];
    #virtualisation.spiceUSBRedirection.enable = true;
    # common settings
    boot.extraModprobeConfig = ''
      options kvm ignore_msrs=1
      options kvm report_ignored_msrs=0
      options vfio-pci ids=${builtins.concatStringsSep "," pciIds}
    '';
    ragon.services.libvirt.enable = true;




    systemd.tmpfiles.rules = [
      "f /dev/shm/scream-ivshmem 0660 ${config.ragon.user.username} qemu-libvirtd -"
    ];

    systemd.user.services.scream-ivshmem = {
      enable = true;
      description = "Scream IVSHMEM";
      serviceConfig = {
        ExecStart = "${pkgs.scream}/bin/scream -m /dev/shm/scream-ivshmem-${name}";
        Restart = "always";
      };
      wantedBy = [ "default.target" ];
      requires = [ "pulseaudio.service" ];
    };

    boot.kernelParams = [
      "intel_iommu=on"
      "iommu=pt"
    ];
    boot.initrd.preDeviceCommands = ''
      DEVS="${builtins.concatStringsSep " " pciAddrs}"
      for DEV in $DEVS; do
        echo "vfio-pci" > /sys/bus/pci/devices/$DEV/driver_override
      done
      modprobe -i vfio-pci
    '';
    virtualisation.libvirtd = {
      enable = true;
      onShutdown = "shutdown";
      qemuPackage = pkgs.qemu_kvm;
      qemuVerbatimConfig = ''
        user = "+${toString config.ragon.user.uid}"
        group = "wheel"
        cgroup_device_acl = [
            "/dev/input/by-id/usb-Logitech_USB_Receiver-if02-event-mouse","/dev/input/by-id/usb-04d9_USB-HID_Keyboard-event-kbd",
            "/dev/null", "/dev/full", "/dev/zero",
            "/dev/random", "/dev/urandom",
            "/dev/ptmx", "/dev/kvm"
        ]
      '';

    };

  };
}
