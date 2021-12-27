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

        } // lib.optionalAttrs isGui {
        };
      };
  };
}
