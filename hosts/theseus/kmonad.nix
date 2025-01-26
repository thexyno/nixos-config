{ pkgs, lib, ... }: {
  services.kmonad = {
    enable = true;
    keyboards = {
      builtin = {
        device = "/dev/input/by-path/platform-i8042-serio-0-event-kbd";
        config = builtins.readFile ./builtin.kbd;
      };
      k70-office = {
        device = "/dev/input/by-id/usb-Corsair_CORSAIR_K70_CORE_RGB_TKL_Mechanical_Gaming_Keyboard_599A4D472DCAC05584072AFB922E3BFB-event-kbd";
        config = builtins.readFile ./razer.kbd;

      };
    };
  };

}
