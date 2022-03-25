{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.hardware.hifiberry-dac;
in
{
  options.ragon.hardware.hifiberry-dac.enable = lib.mkEnableOption "Enables hifiberry dac";
  config = lib.mkIf cfg.enable {
    hardware.deviceTree = {
      overlays = [
        # Equivalent to: https://github.com/raspberrypi/linux/blob/rpi-5.10.y/arch/arm/boot/dts/overlays/hifiberry-dac-overlay.dts
        {
          name = "hifiberry-dac-overlay";
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
        }
      ];
    };
  };
}
