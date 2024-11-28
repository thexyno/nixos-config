{ pkgs, lib, ... }: {
  services.kmonad = {
    enable = true;
    keyboards = {
      builtin = {
        device = "/dev/input/by-path/platform-i8042-serio-0-event-kbd";
        config = builtins.readFile ./builtin.kbd;
      };
      razerbuero = {
        device = "/dev/input/by-id/usb-Razer_Razer_BlackWidow_Tournament_Edition_Chroma-event-kbd";
        config = builtins.readFile ./razer.kbd;

      };
    };
  };

}
