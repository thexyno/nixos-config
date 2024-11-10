{ pkgs, lib, ... }: {
  services.kmonad = {
 enable = true;
   keyboards = {
     builtin= {
       device = "/dev/input/by-path/platform-i8042-serio-0-event-kbd";
       config = builtins.readFile ./builtin.kbd;
     };
   };
};
  
}
