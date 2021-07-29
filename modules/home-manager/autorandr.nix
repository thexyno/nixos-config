{ inputs, config, lib, pkgs, ... }:
let
  cfg = config.ragon.home-manager;
  isGui = config.ragon.gui.enable;
in
{
  config = lib.mkIf cfg.enable {
    home-manager.users.${config.ragon.user.username} = { pkgs, lib, ... }:
    {
      programs.autorandr.enable = true;
      programs.autorandr.profiles = {
            "tv" = {
              fingerprint = {
                HDMI-1 = "00ffffffffffff004dd901ee010101010114010380a05a780a0dc9a05747982712484c21080081800101010101010101010101010101023a801871382d40582c450040846300001e011d007251d01e206e28550040846300001e000000fc00534f4e592054560a2020202020000000fd00303e0e460f000a20202020202001be02032cf0501f101405130412111615030207060120260907071507508301000068030c001000b82d0fe2007b023a80d072382d40102c458040846300001e011d00bc52d01e20b828554040846300001e011d8018711c1620582c250040846300009e011d80d0721c1620102c258040846300009e00000000000000000000000e";
                eDP-1 = "00ffffffffffff000daec91400000000081a0104951f11780228659759548e271e505400000001010101010101010101010101010101b43b804a71383440503c680035ad10000018000000fe004e3134304843412d4541420a20000000fe00434d4e0a202020202020202020000000fe004e3134304843412d4541420a20003e";
              };
              config = {
                VGA-1.enable = false;
                DP-1.enable = false;
                DP-2.enable = false;
                HDMI-2.enable = false;
                eDP-1 = {
                  enable = true;
                  crtc = 1;
                  mode = "1920x1080";
                  position = "0x0";
                  rate = "60.01";
                };
                HDMI-1 = {
                  enable = true;
                  crtc = 1;
                  mode = "1920x1080";
                  position = "0x0";
                  rate = "60.00";
                };

              };


            };
            "work" = {
              fingerprint = {
                DP-2-2 = "00ffffffffffff0005e30124b24407001d1e010380341d782a9b15a655519d260d5054bfef00d1c0b30095008180814081c001010101023a801871382d40582c450009252100001e000000ff00474d584c374841343736333338000000fc0032344231570a20202020202020000000fd00324c1e5311000a202020202020011802031ef14b101f051404130312021101230907078301000065030c0010008c0ad08a20e02d10103e9600092521000018011d007251d01e206e28550009252100001e8c0ad08a20e02d10103e96000925210000188c0ad090204031200c40550009252100001800000000000000000000000000000000000000000000000000f1";
                DP-2-3 = "00ffffffffffff0005e30124a96107001f1e010368341d782a9b15a655519d260d5054bfef00d1c0b30095008180814081c001010101023a801871382d40582c450009252100001e000000ff00474d584c384841343833373533000000fc0032344231570a20202020202020000000fd00324c1e5311000a202020202020001b";
                eDP-1 = "00ffffffffffff000daec91400000000081a0104951f11780228659759548e271e505400000001010101010101010101010101010101b43b804a71383440503c680035ad10000018000000fe004e3134304843412d4541420a20000000fe00434d4e0a202020202020202020000000fe004e3134304843412d4541420a20003e";
              };
              config = {
                VGA-1.enable = false;
                DP-1.enable = false;
                HDMI-1.enable = false;
                DP-2.enable = false;
                HDMI-2.enable = false;
                DP-2-1.enable = false;
                DP-2-3 = {
                  enable = true;
                  crtc = 2;
                  mode = "1920x1080";
                  position = "0x0";
                  rate = "60.00";
                };
                DP-2-2 = {
                  enable = true;
                  crtc = 1;
                  mode = "1920x1080";
                  position = "1920x0";
                  rate = "60.00";
                };
                eDP-1 = {
                  enable = true;
                  crtc = 0;
                  mode = "1920x1080";
                  position = "3840x0";
                  rate = "60.01";
                };
              };
            };
          };
    }
  }
