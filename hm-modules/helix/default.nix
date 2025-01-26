{ pkgs, config, lib, inputs, ... }:
let
  cfg = config.ragon.helix;
in
{
  options.ragon.helix.enable = lib.mkOption { default = false; };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      jsonnet-language-server
      jsonnet
      nixpkgs-fmt
      # omnisharp-roslyn
      ## ts
      # nodePackages_latest.prettier
      typescript
      dprint
      nodePackages_latest.typescript-language-server
      nodePackages_latest.vscode-langservers-extracted
      ## python
      ruff-lsp
      # nodePackages_latest.pyright
      inputs.roslyn-language-server.packages.${pkgs.system}.roslyn-language-server
      netcoredbg
    ];
    programs.helix = {
      package = inputs.helix.packages.${pkgs.system}.default;
      enable = true;
      defaultEditor = true;
      settings = {
        theme = "gruvbox_dark_hard";
        editor = {
          line-number = "relative";
          lsp.display-messages = true;
        };
      };
      languages = {
        language-server.pyright.config.python.analysis.typeCheckingMode = "basic";
        language-server.ruff = {
          command = "ruff-lsp";
          config.settings.args = [ "--ignore" "E501" ];
        };
        language-server.roslyn = {
          command = "roslyn-language-server";
        };
        language = lib.flatten [
          (map
            (x: {
              name = x;
              language-servers = [ "typescript-language-server" "eslint" ];
              #formatter = { command = "dprint"; args = [ "fmt" "--stdin" x ]; };
              # formatter = { command = "prettier"; args = [ "--parser" "typescript" ]; };
            }) [ "typescript" "javascript" "jsx" "tsx" ])
          {
            name = "nix";
            formatter = { command = "nixpkgs-fmt"; };
          }
          {
            name = "python";
            language-servers = [ "pyright" "ruff" ];
          }
          {
            name = "c-sharp";
            language-servers = [ "roslyn" ];
            formatter = { command = "dotnet"; args = [ "csharpier" ]; };

          }
        ];
      };
    };
  };
}
