{ inputs, config, lib, pkgs, ... }:
let
  cfg = config.ragon.home-manager;
  isGui = config.ragon.gui.enable;
in
{
  config = lib.mkIf cfg.enable {
    home-manager.users.${config.ragon.user.username} = { pkgs, lib, ... }:
    {
        home.file = {
          # Home nix config.
          ".config/nixpkgs/config.nix".text = "{ allowUnfree = true; }";
          ".local/share/pandoc/templates/default.latex".source = "${inputs.pandoc-latex-template}/eisvogel.tex";

          # Nano config
          ".nanorc".text = "set constantshow # Show linenumbers -c as default";
          # empty zshrc to stop zsh-newuser-install from running
          ".zshrc".text = "";

          "bin/changeVolume".source = ../bins/changeVolume;
          "bin/devsaurgit".source = ../bins/devsaurgit;
          "bin/getProgressString".source = ../bins/getProgressString;
          "bin/swapDevices".source = ../bins/swapDevices;
          "bin/toggleSpeakers".source = ../bins/toggleSpeakers;
          "bin/nosrebuild".source = ../bins/nosrebuild;
        } // lib.optionalAttrs isGui {
          "bin/changeBacklight".source = ../bins/changeBacklight;
          "bin/nextshot".source = "${inputs.nextshot}/nextshot.sh";
        };
    }
  }
