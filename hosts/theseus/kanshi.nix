{ pkgs, inputs, options, lib, ... }:
let
  # TODO: have a list of workspaces and operate on that
  moveWs = output: workspaceStart: workspaceEnd: map
    (x: ''${pkgs.sway}/bin/swaymsg workspace ${toString x}:${toString x} ouptut "${output}", workspace ${toString x}:${toString x}, move workspace to "${output}"'')
    (lib.range workspaceStart workspaceEnd);
in
{
  services.kanshi = {
    enable = true;
    settings = [
      {
        profile.name = "undocked";
        profile.outputs = [
          {
            criteria = "eDP-1";
            adaptiveSync = true;
            scale = 1.25;
            mode = "2880x1920@120Hz";
          }
        ];
      }
      {
        profile.name = "docked_home";
        profile.outputs = [
          {
            criteria = "eDP-1";
            adaptiveSync = true;
            scale = 2.0;
            mode = "2880x1920@120Hz";
          }
          {
            criteria = "Dell Inc. Dell S2716DG #ASM2LrMXJiXd";
            adaptiveSync = true;
            position = "1440,0";
            scale = 1.0;
            mode = "2560x1440@119.998Hz";
          }
          {
            criteria = "Acer Technologies KG271U TATEE0018511";
            adaptiveSync = true;
            position = "4000,0";
            scale = 1.0;
            mode = "2560x1440@74.924Hz";
          }
        ];
        profile.exec =  lib.flatten [
          (moveWs "eDP-1" 1 3)
          (moveWs "Dell Inc. Dell S2716DG #ASM2LrMXJiXd" 4 7)
          (moveWs "Acer Technologies KG271U TATEE0018511" 8 10)
        ];
      }
    ];
  };
}
