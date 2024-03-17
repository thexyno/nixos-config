{ inputs, config, lib, pkgs, ... }:
{
  imports = [
    "${inputs.impermanence}/home-manager.nix"
  ];
        home.file = {
          # Home nix config.
          ".config/nixpkgs/config.nix".text = "{ allowUnfree = true; }";
          ".local/share/pandoc/templates/default.latex".source = "${inputs.pandoc-latex-template}/eisvogel.tex";

          # empty zshrc to stop zsh-newuser-install from running
          ".zshrc".text = "";

        };
}
