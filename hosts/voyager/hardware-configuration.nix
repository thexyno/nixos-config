# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ inputs, config, lib, pkgs, modulesPath, ... }:

{
  imports = [ "${modulesPath}/installer/scan/not-detected.nix" 
  inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t440p
];

  boot.initrd.availableKernelModules = [ "ahci" "vfio-pci" "xhci_pci" "ehci_pci" "usbhid" "sd_mod" "sr_mod" ];
  boot.initrd.luks.devices.crypt.device = "/dev/sda1";
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
  nix.maxJobs = lib.mkDefault 8;
  ragon.system.fs.enable = true;
  ragon.hardware.laptop.enable = true;
}