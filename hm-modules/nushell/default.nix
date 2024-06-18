{ pkgs, config, lib, inputs, ... }:
let
  cfg = config.ragon.nushell;
  aliasesJson = pkgs.writeText "shell-aliases.json" (builtins.toJSON config.home.shellAliases);
in
{
  options.ragon.nushell.enable = lib.mkOption { default = false; };
  config = lib.mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      enableNushellIntegration = true;
    };
    programs.nushell = {
      enable = true;
            extraConfig = ''
       let carapace_completer = {|spans|
       carapace $spans.0 nushell ...$spans | from json
       }
       $env.config = {
        edit_mode: vi
        show_banner: false,
        completions: {
        case_sensitive: false # case-sensitive completions
        quick: true    # set to false to prevent auto-selecting completions
        partial: true    # set to false to prevent partial filling of the prompt
        algorithm: "fuzzy"    # prefix or fuzzy
        external: {
        # set to false to prevent nushell looking into $env.PATH to find more suggestions
            enable: true 
        # set to lower can improve completion performance at the cost of omitting some options
            max_results: 100 
            completer: $carapace_completer # check 'carapace_completer' 
          }
        }
       } 
      $env.NIX_REMOTE = "daemon"
      $env.NIX_USER_PROFILE_DIR = $"/nix/var/nix/profiles/per-user/($env.USER)"
      $env.NIX_PROFILES = $"/nix/var/nix/profiles/default:($env.HOME)/.nix-profile"
      $env.NIX_SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt"
      $env.NIX_PATH = "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixpkgs:/nix/var/nix/profiles/per-user/root/channels"
      $env.PATH = ($env.PATH | 
      split row (char esep) |
      append /usr/bin/env |
      append $"($env.HOME)/.nix-profile/bin" |
      append "/nix/var/nix/profiles/default/bin" |
      append $"/etc/profiles/per-user/($env.USER)/bin" |
      append "/run/current-system/sw/bin" |
      append "/opt/homebrew/bin" |
      append $"($env.HOME)/.cargo/bin" |
      append $"($env.HOME)/.local/bin"
      )
      alias no = open
      alias open = ^open
      alias l = ls -al
      alias ll = ls -l
      alias ga = git add
      alias gaa = git add -A
      alias gd = git diff
      alias gc = git commit
      alias gp = git push
      alias gpl = git pull
       '';
       shellAliases = {
       vi = "hx";
       vim = "hx";
       nano = "hx";
       };
   };  
   programs.carapace.enable = true;
   programs.carapace.enableNushellIntegration = true;

   programs.starship = { enable = true;
       settings = {
         add_newline = false;
         character = { 
         success_symbol = "[➜](bold green)";
         error_symbol = "[➜](bold red)";
       };
    };
    };
    programs.vscode.userSettings."terminal.integrated.profiles.osx" = {
      nushell = {
        path = "${pkgs.nushell}/bin/nushell";
      };
    };
    programs.vscode.userSettings."terminal.integrated.defaultProfile.osx" = "nushell";
  };
}
