{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.gamingvmhost;
  name = cfg.name;
in
{
  options.ragon.gamingvmhost = {
    enable = lib.mkEnableOption "Enables vm stuff";
    name = lib.mkOption {
      type = lib.types.str;
      default = "gamingvm";
    };
  };
  config = lib.mkIf cfg.enable {

    programs.dconf.enable = true;
    environment.systemPackages = with pkgs; [
#      scream-recievers
      virt-manager ];
    #virtualisation.spiceUSBRedirection.enable = true;
    # common settings
    boot.extraModprobeConfig = ''
      options kvm ignore_msrs=1
      options kvm report_ignored_msrs=0
      options vfio-pci ids=10de:1b80,10de:10f0,1912:0015
    '';
    ragon.user.extraGroups = [ "kvm" "libvirt" ];

     	

    systemd.tmpfiles.rules = [
      "f /dev/shm/scream-ivshmem 0660 alex qemu-libvirtd -"
    ];
    
    systemd.user.services.scream-ivshmem = {
      enable = true;
      description = "Scream IVSHMEM";
      serviceConfig = {
        ExecStart = "${pkgs.scream-receivers.override { pulseSupport = true; }}/bin/scream-ivshmem-pulse /dev/shm/scream-ivshmem-${name}";
        Restart = "always";
      };
      wantedBy = [ "multi-user.target" ];
      requires = [ "pulseaudio.service" ];
    };

    boot.kernelParams = [
      "intel_iommu=on"
      "iommu=pt"
    ];
    boot.initrd.preDeviceCommands = ''
      DEVS="0000:06:00.0 0000:06:00.1"
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
            "/dev/input/by-id/usb-Logitech_Gaming_Mouse_G502_138334633633-event-mouse","/dev/input/by-id/usb-04d9_USB-HID_Keyboard-event-kbd","/dev/input/by-id/usb-Logitech_Gaming_Mouse_G502_138334633633-if01-event-kbd",
            "/dev/null", "/dev/full", "/dev/zero",
            "/dev/random", "/dev/urandom",
            "/dev/ptmx", "/dev/kvm"
        ]
      '';

    };
    # define gaming vm
    systemd.services."libvirtd-guest-gamingvm" =
     {
      after = [ "libvirtd.service" ];
      requires = [ "libvirtd.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = "yes";
      };
      script =
        let
          xml = pkgs.writeText "libvirt-guest-${name}.xml"
            ''
              <domain type='kvm' xmlns:qemu='http://libvirt.org/schemas/domain/qemu/1.0'>
                <name>${name}</name>
                <uuid>UUID</uuid>
                <metadata>
                  <libosinfo:libosinfo xmlns:libosinfo="http://libosinfo.org/xmlns/libvirt/domain/1.0">
                    <libosinfo:os id="http://microsoft.com/win/10"/>
                  </libosinfo:libosinfo>
                </metadata>
                <memory unit='KiB'>16777216</memory>
                <currentMemory unit='KiB'>16777216</currentMemory>
                <vcpu placement='static'>10</vcpu>
                <cputune>
                  <vcpupin vcpu='0' cpuset='1'/>
                  <vcpupin vcpu='1' cpuset='2'/>
                  <vcpupin vcpu='2' cpuset='3'/>
                  <vcpupin vcpu='3' cpuset='4'/>
                  <vcpupin vcpu='4' cpuset='5'/>
                  <vcpupin vcpu='5' cpuset='7'/>
                  <vcpupin vcpu='6' cpuset='8'/>
                  <vcpupin vcpu='7' cpuset='9'/>
                  <vcpupin vcpu='8' cpuset='10'/>
                  <vcpupin vcpu='9' cpuset='11'/>
                </cputune>
                <os>
                  <type arch='x86_64' machine='pc-q35-5.2'>hvm</type>
                  <loader readonly='yes' type='pflash'>${pkgs.OVMF.fd}/FV/OVMF_CODE.fd</loader>
                  <nvram>/tmp/OVMF_VARS.fd</nvram>
                  <bootmenu enable='no'/>
                </os>
                <features>
                  <acpi/>
                  <apic/>
                  <hyperv>
                    <vendor_id state='on' value='NvIdIaBitCh1'/>
                  </hyperv>
                  <kvm>
                    <hidden state='on'/>
                  </kvm>
                  <vmport state='off'/>
                </features>
                <cpu mode='host-passthrough' check='none' migratable='on'>
                  <topology sockets='1' dies='1' cores='5' threads='2'/>
                </cpu>
                <clock offset='utc'>
                  <timer name='rtc' tickpolicy='catchup'/>
                  <timer name='pit' tickpolicy='delay'/>
                  <timer name='hpet' present='no'/>
                </clock>
                <on_poweroff>destroy</on_poweroff>
                <on_reboot>restart</on_reboot>
                <on_crash>destroy</on_crash>
                <pm>
                  <suspend-to-mem enabled='no'/>
                  <suspend-to-disk enabled='no'/>
                </pm>
                <devices>
                  <emulator>/run/libvirt/nix-emulators/qemu-system-x86_64</emulator>
                  <disk type='block' device='disk'>
                    <driver name='qemu' type='raw' cache='none' io='native'/>
                    <source dev='/dev/disk/by-id/ata-Crucial_CT500MX200SSD1_14500E6E39CA'/>
                    <target dev='sda' bus='scsi'/>
                    <boot order='2'/>
                    <address type='drive' controller='0' bus='0' target='0' unit='0'/>
                  </disk>
                  <disk type='block' device='disk'>
                    <driver name='qemu' type='raw' cache='none' io='native'/>
                    <source dev='/dev/disk/by-id/ata-SanDisk_SSD_PLUS_1000GB_190778801512'/>
                    <target dev='sdb' bus='scsi'/>
                    <address type='drive' controller='0' bus='0' target='0' unit='1'/>
                  </disk>
                  <controller type='usb' index='0' model='qemu-xhci' ports='15'>
                    <address type='pci' domain='0x0000' bus='0x02' slot='0x00' function='0x0'/>
                  </controller>
                  <controller type='scsi' index='0' model='virtio-scsi'>
                    <address type='pci' domain='0x0000' bus='0x03' slot='0x00' function='0x0'/>
                  </controller>
                  <controller type='pci' index='0' model='pcie-root'/>
                  <controller type='pci' index='1' model='pcie-root-port'>
                    <model name='pcie-root-port'/>
                    <target chassis='1' port='0x8'/>
                    <address type='pci' domain='0x0000' bus='0x00' slot='0x01' function='0x0' multifunction='on'/>
                  </controller>
                  <controller type='pci' index='2' model='pcie-root-port'>
                    <model name='pcie-root-port'/>
                    <target chassis='2' port='0x9'/>
                    <address type='pci' domain='0x0000' bus='0x00' slot='0x01' function='0x1'/>
                  </controller>
                  <controller type='pci' index='3' model='pcie-root-port'>
                    <model name='pcie-root-port'/>
                    <target chassis='3' port='0xa'/>
                    <address type='pci' domain='0x0000' bus='0x00' slot='0x01' function='0x2'/>
                  </controller>
                  <controller type='pci' index='4' model='pcie-root-port'>
                    <model name='pcie-root-port'/>
                    <target chassis='4' port='0xb'/>
                    <address type='pci' domain='0x0000' bus='0x00' slot='0x01' function='0x3'/>
                  </controller>
                  <controller type='pci' index='5' model='pcie-root-port'>
                    <model name='pcie-root-port'/>
                    <target chassis='5' port='0xc'/>
                    <address type='pci' domain='0x0000' bus='0x00' slot='0x01' function='0x4'/>
                  </controller>
                  <controller type='pci' index='6' model='pcie-root-port'>
                    <model name='pcie-root-port'/>
                    <target chassis='6' port='0xd'/>
                    <address type='pci' domain='0x0000' bus='0x00' slot='0x01' function='0x5'/>
                  </controller>
                  <controller type='pci' index='7' model='pcie-root-port'>
                    <model name='pcie-root-port'/>
                    <target chassis='7' port='0xe'/>
                    <address type='pci' domain='0x0000' bus='0x00' slot='0x01' function='0x6'/>
                  </controller>
                  <controller type='pci' index='8' model='pcie-root-port'>
                    <model name='pcie-root-port'/>
                    <target chassis='8' port='0xf'/>
                    <address type='pci' domain='0x0000' bus='0x00' slot='0x01' function='0x7'/>
                  </controller>
                  <controller type='pci' index='9' model='pcie-root-port'>
                    <model name='pcie-root-port'/>
                    <target chassis='9' port='0x10'/>
                    <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x0'/>
                  </controller>
                  <controller type='pci' index='10' model='pcie-to-pci-bridge'>
                    <model name='pcie-pci-bridge'/>
                    <address type='pci' domain='0x0000' bus='0x08' slot='0x00' function='0x0'/>
                  </controller>
                  <controller type='sata' index='0'>
                    <address type='pci' domain='0x0000' bus='0x00' slot='0x1f' function='0x2'/>
                  </controller>
                  <interface type='direct'>
                    <mac address='52:54:00:f3:ab:dd'/>
                    <source dev='enp9s0' mode='bridge'/>
                    <model type='virtio'/>
                    <address type='pci' domain='0x0000' bus='0x07' slot='0x00' function='0x0'/>
                  </interface>
                  <input type='mouse' bus='virtio'>
                    <address type='pci' domain='0x0000' bus='0x00' slot='0x0e' function='0x0'/>
                  </input>
                  <input type='keyboard' bus='virtio'>
                    <address type='pci' domain='0x0000' bus='0x00' slot='0x0f' function='0x0'/>
                  </input>
                  <input type='mouse' bus='ps2'/>
                  <input type='keyboard' bus='ps2'/>
                  <hostdev mode='subsystem' type='pci' managed='yes'>
                    <source>
                      <address domain='0x0000' bus='0x06' slot='0x00' function='0x0'/>
                    </source>
                    <address type='pci' domain='0x0000' bus='0x04' slot='0x00' function='0x0'/>
                  </hostdev>
                  <hostdev mode='subsystem' type='pci' managed='yes'>
                    <source>
                      <address domain='0x0000' bus='0x06' slot='0x00' function='0x1'/>
                    </source>
                    <address type='pci' domain='0x0000' bus='0x05' slot='0x00' function='0x0'/>
                  </hostdev>
                  <redirdev bus='usb' type='spicevmc'>
                    <address type='usb' bus='0' port='1'/>
                  </redirdev>
                  <redirdev bus='usb' type='spicevmc'>
                    <address type='usb' bus='0' port='2'/>
                  </redirdev>
                  <memballoon model='virtio'>
                    <address type='pci' domain='0x0000' bus='0x06' slot='0x00' function='0x0'/>
                  </memballoon>
                  <shmem name='scream-ivshmem-${name}'>
                    <model type='ivshmem-plain'/>
                    <size unit='M'>2</size>
                    <address type='pci' domain='0x0000' bus='0x0a' slot='0x01' function='0x0'/>
                  </shmem>
                </devices>
                <qemu:commandline>
                  <qemu:arg value='-object'/>
                  <qemu:arg value='input-linux,id=mouse1,evdev=/dev/input/by-id/usb-Logitech_Gaming_Mouse_G502_138334633633-event-mouse'/>
                  <qemu:arg value='-object'/>
                  <qemu:arg value='input-linux,id=kbd1,evdev=/dev/input/by-id/usb-04d9_USB-HID_Keyboard-event-kbd,grab_all=on,repeat=on'/>
                  <qemu:arg value='-object'/>
                  <qemu:arg value='input-linux,id=kbd2,evdev=/dev/input/by-id/usb-Logitech_Gaming_Mouse_G502_138334633633-if01-event-kbd,grab_all=on,repeat=on'/>
                </qemu:commandline>
              </domain>
            '';
        in
          ''
            if ! (${pkgs.libvirt}/bin/virsh list --all | grep -q ${name}); then
              uuid="$(${pkgs.libvirt}/bin/virsh domuuid '${name}' || true)"
              ${pkgs.libvirt}/bin/virsh define <(sed "s/UUID/$uuid/" '${xml}')
              cp ${pkgs.OVMF.fd}/FV/OVMF_VARS.fd /tmp/OVMF_VARS.fd
              chmod 777 /tmp/OVMF_VARS.fd
            fi
            ${pkgs.libvirt}/bin/virsh start '${name}' || true # ignore fail
          '';
      preStop = "";
      #preStop =
      #  ''
      #    ${pkgs.libvirt}/bin/virsh shutdown '${name}'
      #    let "timeout = $(date +%s) + 10"
      #    while [ "$(${pkgs.libvirt}/bin/virsh list --name | grep --count '^${name}$')" -gt 0 ]; do
      #      if [ "$(date +%s)" -ge "$timeout" ]; then
      #        # Meh, we warned it...
      #        ${pkgs.libvirt}/bin/virsh destroy '${name}'
      #      else
      #        # The machine is still running, let's give it some time to shut down
      #        sleep 0.5
      #      fi
      #    done
      #  '';
    };


  };
}

