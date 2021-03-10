{ config, pkgs, ... }:

{
  imports = [
    ./kitty.nix
    ./user.nix
#    ./development/default.nix
  ];
  # Enable dwm
  services.xserver.enable = true;
  services.xserver.displayManager.defaultSession = "none+dwm";
  services.xserver.windowManager.dwm.enable = true;
  # Configure keymap in X11
  services.xserver.layout = "de";
  services.xserver.xkbOptions = "caps:swapescape";
  # Enable CUPS to print documents.
  services.printing.enable = true;
  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  # VM Stuff
  services.spice-vdagentd.enable = true;
  services.qemuGuest.enable = true;

  # auto update
  system.autoUpgrade.enable = true;

  environment.systemPackages = with pkgs; [
    firefox
  ];
  nixpkgs.overlays = [
    (self: super: {
      dwm = super.dwm.overrideAttrs (oldAttrs: rec {
        src = fetchTarball {
          url = "https://gitlab.hochkamp.eu/ragon/dwm/-/archive/master.tar.gz";
        };
      });
    }
    )
  ];
}
