{ config, inputs, pkgs, lib, ... }:
{
  #imports = [
  #  "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
  #];
  ragon.hardware.rpi3.enable = true;
  sound.enable = true;
  documentation.enable = false;
  documentation.nixos.enable = false;
  networking.interfaces.wlan0.useDHCP = true;
  networking.interfaces.eth0.useDHCP = true;

  nix = {
    autoOptimiseStore = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    # Free up to 1GiB whenever there is less than 100MiB left.
    extraOptions = ''
      min-free = ${toString (100 * 1024 * 1024)}
      max-free = ${toString (1024 * 1024 * 1024)}
    '';
  };
  system.autoUpgrade.enable = true;
  system.autoUpgrade.flake = "github:ragon000/nixos-config";
  system.autoUpgrade.allowReboot = true;
  powerManagement.cpuFreqGovernor = "ondemand";

  # Assuming this is installed on top of the disk image.
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  hardware.deviceTree.overlays = [{
    name = "hifiberry-dac";
    dtsText = ''
      // Definitions for HiFiBerry DAC
      /dts-v1/;
      /plugin/;
      
      / {
      	compatible = "brcm,bcm2835";
      
      	fragment@0 {
      		target = <&i2s>;
      		__overlay__ {
      			status = "okay";
      		};
      	};
      
      	fragment@1 {
      		target-path = "/";
      		__overlay__ {
      			pcm5102a-codec {
      				#sound-dai-cells = <0>;
      				compatible = "ti,pcm5102a";
      				status = "okay";
      			};
      		};
      	};
      
      	fragment@2 {
      		target = <&sound>;
      		__overlay__ {
      			compatible = "hifiberry,hifiberry-dac";
      			i2s-controller = <&i2s>;
      			status = "okay";
      		};
      	};
      };
    '';

  }];
  #hardware.pulseaudio.extraConfig = ''
  #  unload-module module-native-protocol-unix
  #  load-module module-native-protocol-unix auth-anonymous=1
  #'';
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.systemWide = true;
  hardware.pulseaudio.tcp = {
    enable = true;
    anonymousClients.allowAll = true;
  };
  hardware.pulseaudio.zeroconf.publish.enable = true;

  ragon.user.enable = true;
  ragon.services.ssh.enable = true;
  security.sudo.wheelNeedsPassword = false;
  services.spotifyd.enable = true;
  services.spotifyd.config = ''
    [global]
    backend = "pulseaudio"
    bitrate = 320
    device_name = "Küche"
  '';
  ragon.agenix.enable = false;
  networking.firewall.enable = false; # danger zone
}
