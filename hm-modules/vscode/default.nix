{ pkgs, config, lib, inputs, ... }:
let
  cfg = config.ragon.vscode;
  #marketplace = inputs.nix-vscode-extensions.extensions.${pkgs.system}.vscode-marketplace;
  #marketplace-release = inputs.nix-vscode-extensions.extensions.${pkgs.system}.vscode-marketplace-release;
  marketplace = (import ./vscode-extensions.nix { inherit pkgs lib; });

in
{
  options.ragon.vscode.enable = lib.mkOption { default = false; };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      nixd
      nixpkgs-fmt
      (unstable.quarto.overrideAttrs (curr: { meta.platforms = [ pkgs.system ]; }))
    ];
    programs.vscode = {
      enable = true;
      package = pkgs.unstable.vscode;
      #mutableExtensionsDir = false;
      extensions = with marketplace; [
        vscodevim.vim # vim mode (hopefully good)
        fathulfahmy.lunarkeymap
        vspacecode.whichkey
        jdinhlife.gruvbox # theme
        mkhl.direnv # direnv

        
        marketplace.eamodio.gitlens
        marketplace.ms-vscode-remote.remote-containers

        marketplace.sonarsource.sonarlint-vscode


        # tomoki1207.pdf # reenable when latex workshop goes

        marketplace.johnpapa.vscode-peacock # colors per workspace


        # Language Support 
        ## markdown/latex
        marketplace.james-yu.latex-workshop # latex, also provides pdf preview
        marketplace.quarto.quarto
        # marketplace.pokey.cursorless # too much xe exposure
        marketplace.valentjn.vscode-ltex # languagetool
        #valentjn.vscode-ltex
        #marketplace.gpoore.codebraid-preview
        marketplace.ms-vscode.hexeditor # a hex editor
        #ms-vscode-remote.remote-containers # container envs for stuff
        marketplace.ms-vscode-remote.remote-ssh



        ## others
        marketplace.vscjava.vscode-java-pack # java schmava
        marketplace.vscjava.vscode-java-debug
        marketplace.vscjava.vscode-java-test
        marketplace.vscjava.vscode-java-dependency
        marketplace.vscjava.vscode-maven
        marketplace.redhat.java
        marketplace.ms-vscode.cpptools-extension-pack # cpp
        # marketplace.ms-vscode.cmake-tools # broken rn
        marketplace.ms-vscode.cpptools
        marketplace.ms-azuretools.vscode-docker # docker
        jnoortheen.nix-ide # nix
        golang.go # go
        marketplace.ms-python.python # python
        marketplace.ms-python.vscode-pylance # python
        #marketplace.ms-python.debugpy # python
        marketplace.donjayamanne.python-environment-manager # python
        marketplace.denoland.vscode-deno # deno
        marketplace.bradlc.vscode-tailwindcss
        #ms-dotnettools.csharp # c# und so
        #marketplace.ms-dotnettools.csdevkit
        # marketplace.ms-dotnettools.csharp
        # marketplace.ms-dotnettools.vscode-dotnet-runtime
        # (marketplace.ms-dotnettools.csdevkit.overrideAttrs (super: a: { sourceRoot = "."; }))
        rust-lang.rust-analyzer # rust
        marketplace.sswg.swift-lang # swift
        #marketplace.vadimcn.vscode-lldb # swift
        #marketplace.ms-toolsai.jupyter # jupiter notebooks, broken on 2023-12-19
        marketplace.ms-toolsai.jupyter-renderers
        #ms-toolsai.jupyter
        #marketplace.jakebecker.elixir-ls # elixir
        marketplace.dart-code.flutter # dart/flutter
        marketplace.dart-code.dart-code # dart/flutter
        marketplace.alexisvt.flutter-snippets # flutter snippets
        marketplace.tauri-apps.tauri-vscode # tauri
        marketplace.dbaeumer.vscode-eslint # js
        marketplace.firefox-devtools.vscode-firefox-debug # js debugging
        marketplace.arcanis.vscode-zipfs # yarn

        marketplace.foam.foam-vscode
        marketplace."vsls-contrib"."gitdoc"
        yzhang.markdown-all-in-one # markdown
        marketplace.davidanson.vscode-markdownlint
        marketplace.bierner.markdown-mermaid
        marketplace.bpruitt-goddard.mermaid-markdown-syntax-highlighting
        marketplace.bierner.markdown-footnotes
        marketplace.hediet.vscode-drawio
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      ];
      userSettings =
        let
          fontFamily = "'JetBrainsMono Nerd Font', monospace";
        in
        {
          "editor.fontFamily" = fontFamily;
          "terminal.integrated.fontFamily" = fontFamily;
          "terminal.integrated.scrollback" = 20000;
          "workbench.colorTheme" = "Gruvbox Dark Soft";
          "editor.autoClosingBrackets" = "never";
          "editor.autoClosingQuotes" = "never";
          "editor.minimap.autohide" = true;

          "editor.tabCompletion" = "onlySnippets";
          #"editor.snippetSuggestions" = "top";

          # Addon Configuration

          ## Vim
          "vim.leader" = "<space>";
          # "vim.normalModeKeyBindings" = [
          #   { before = [ "<C-h>" ]; after = [ "<C-w>" "h" ]; }
          #   { before = [ "<C-j>" ]; after = [ "<C-w>" "j" ]; }
          #   { before = [ "<C-k>" ]; after = [ "<C-w>" "k" ]; }
          #   { before = [ "<C-l>" ]; after = [ "<C-w>" "l" ]; }
          # ];
          "vim.normalModeKeyBindingsNonRecursive" = [
            # {
            #   before = [ "<leader>" "s" ];
            #   "commands" = [ "workbench.action.splitEditor" ];
            #   quiet = true;
            # }
            # {
            #   before = [ "<leader>" "a" "s" ];
            #   "commands" = [ "workbench.action.splitEditorDown" ];
            #   quiet = true;
            # }
            {
              before = [ "<leader>" "q" ];
              "commands" = [ "workbench.action.closeActiveEditor" ];
              quiet = true;
            }
            {
              before = [ "<leader>" "c" "a" ];
              "commands" = [ "editor.action.sourceAction" ];
              quiet = true;
            }
            {
              before = [ "<leader>" "r" "n" ];
              "commands" = [ "editor.action.rename" ];
              quiet = true;
            }
            {
              before = [ "<leader>" "c" "f" ];
              "commands" = [ "editor.action.quickFix" ];
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
              before = [ "<leader>" "g" "r" ];
              "commands" = [ "editor.action.goToReferences" ];
              quiet = true;
            }
          ];
          "vim.useSystemClipboard" = false;
          "vim.handleKeys" = {
            "<C-w>" = false;
          };
          "vim.camelCaseMotion.enable" = true;
          ## git
          "git.verboseCommit" = true;
          "git.allowForcePush" = true;
          "git.confirmSync" = false;
          "git.confirmForcePush" = true; # is default but it feels safer to also specify it here
          "git.useForcePushWithLease" = true; # is default but it feels safer to also specify it here
          ## Nix
          "nix.serverPath" = "nixd";
          "nix.enableLanguageServer" = true;
          "nix.serverSettings" = {
            "nixd" = {
              "formatting" = {
                "command" = "nixpkgs-fmt";
              };
            };
          };
          ## dart/flutter
          "[dart]" = {
            "editor.formatOnSave" = true;
            "editor.formatOnType" = true;
            "editor.rulers" = [ 80 ];
            "editor.selectionHighlight" = false;
            "editor.suggestSelection" = "first";
            "editor.tabCompletion" = "onlySnippets";
            "editor.wordBasedSuggestions" = "off";
          };
          ## md preview
          #"codebraid.preview.pandoc.build" = {
          #  "*.md" = {
          #    "reader" = "markdown"; # use pandoc markdown and not commonmark
          #    "preview" = { "html" = { defaults = {}; options = []; }; };
          #  };
          #};
          # swift
          "lldb.library" = "/Applications/Xcode.app/Contents/SharedFrameworks/LLDB.framework/Versions/A/LLDB";
          "lldb.launch.expressions" = "native";
          # ltex-ls
          #"ltex.language" = "de";
          #"ltex.ltex-ls.path" = "${pkgs.ltex-ls}";
          #"ltex.ltex-ls.logLevel" = "finest";
          #"ltex.trace.server" = "verbose";
          # idk
          "hediet.vscode-drawio.resizeImages" = "null";

        };
        keybindings = [
          { "key" = "ctrl+w"; "command" = "whichkey.show"; }
        ];
    };
  };
}
