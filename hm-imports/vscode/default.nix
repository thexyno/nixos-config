{ pkgs, config, lib, inputs, ... }:
let
  cfg = config.ragon.vscode;
  marketplace = inputs.nix-vscode-extensions.extensions.${pkgs.system}.vscode-marketplace;

in
{
  options.ragon.vscode.enable = lib.mkOption { default = false; };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      nil
      nixpkgs-fmt
    ];
    programs.vscode = {
      enable = true;
      extensions = with pkgs.vscode-extensions; [
        vscodevim.vim # vim mode (hopefully good)
        yzhang.markdown-all-in-one # markdown
        jdinhlife.gruvbox # theme
        mkhl.direnv # direnv
        # tomoki1207.pdf # reenable when latex workshop goes
        shd101wyy.markdown-preview-enhanced


        # Language Support 
        jnoortheen.nix-ide # nix
        golang.go # go
        marketplace.ms-python.python # python
        ms-dotnettools.csharp # c# und so
        rust-lang.rust-analyzer # rust
        marketplace.sswg.swift-lang # swift
        marketplace.james-yu.latex-workshop # latex
        marketplace.ms-toolsai.jupyter # jupiter notebooks

      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      ];
      userSettings =
        let
          fontFamily = "'JetBrainsMono Nerd Font', monospace";
        in
        {
          "editor.fontFamily" = fontFamily;
          "terminal.integrated.fontFamily" = fontFamily;
          "workbench.colorTheme" = "Gruvbox Dark Soft";
          "editor.autoClosingBrackets" = "never";
          "editor.autoClosingQuotes" = "never";
          "editor.minimap.autohide" = true;

          # Addon Configuration

          ## Vim
          "vim.leader" = "<space>";
          "vim.normalModeKeyBindings" = [
            { before = [ "<C-h>" ]; after = [ "<C-w>" "h" ]; }
            { before = [ "<C-j>" ]; after = [ "<C-w>" "j" ]; }
            { before = [ "<C-k>" ]; after = [ "<C-w>" "k" ]; }
            { before = [ "<C-l>" ]; after = [ "<C-w>" "l" ]; }
          ];
          "vim.normalModeKeyBindingsNonRecursive" = [
            {
              before = [ "<leader>" "s" ];
              "commands" = [ "workbench.action.splitEditor" ];
              quiet = true;
            }
            {
              before = [ "<leader>" "a" "s" ];
              "commands" = [ "workbench.action.splitEditorDown" ];
              quiet = true;
            }
            {
              before = [ "<leader>" "q" ];
              "commands" = [ "workbench.action.closeActiveEditor" ];
              quiet = true;
            }
            {
              before = [ "<leader>" "f" ];
              "commands" = [ "editor.action.formatDocument" ];
              quiet = true;
            }
            {
              before = [ "]" "g" ];
              "commands" = [ "editor.action.marker.next" ];
              quiet = true;
            }
            {
              before = [ "[" "g" ];
              "commands" = [ "editor.action.marker.prev" ];
              quiet = true;
            }
            {
              before = [ "<Tab>" ];
              "commands" = [ "workbench.view.explorer" ];
              quiet = true;
            }
            {
              before = [ "<S-Tab>" ];
              "commands" = [ "workbench.action.closeSidebar" ];
              quiet = true;
            }
            {
              before = [ "<leader>" "t" ];
              "commands" = [ "terminal.focus" ];
              quiet = true;
            }
          ];
          ## Nix
          "nix.serverPath" = "nil";
          "nix.enableLanguageServer" = true;
        };
    };
  };
}