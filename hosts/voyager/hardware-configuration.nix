{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" "sd_mod" "sr_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/e852ae04-9863-4820-a452-26b2f6ab8231";
      fsType = "xfs";
    };

  boot.initrd.luks.devices."cryptroot".device = "/dev/disk/by-uuid/76e36f6c-9f91-47fd-a2f7-c135d8d2a6c0";

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/86AF-D2AB";
      fsType = "vfat";
    };

  swapDevices = [ { device = "/dev/disk/by-partuuid/2bbe9b96-6019-4d41-ab2c-da419d24d398"; randomEncryption = true; }  ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp0s25.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlan0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}