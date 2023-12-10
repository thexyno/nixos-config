{ pkgs, config, lib, inputs, ... }:
let
  cfg = config.ragon.xonsh;
  xonsh =
    pkgs.unstable.xonsh.override {
      extraPackages = ps: [
        (ps.buildPythonPackage {
          pname = "xonsh-direnv";
          version = "0.0.0";
          src = inputs.xonsh-direnv;
        })
        (ps.buildPythonPackage {
          pname = "xonsh-fish-completer";
          version = "0.0.0";
          format = "pyproject";
          doCheck = false;
          src = inputs.xonsh-fish-completer;
          propagatedBuildInputs = [
            ps.setuptools
          ];
        })
      ];
    };
in
{
  options.ragon.xonsh.enable = lib.mkOption { default = false; };
  config = lib.mkIf cfg.enable {
    home.packages = [
      xonsh
    ];
    programs.fish.enable = true; # for completions
    home.file.".xonshrc".text = ''
      $PROMPT_FIELDS['rootuser'] = lambda: "{RED}{user}{RESET}" if $USER == "root" else None
      $PROMPT_FIELDS['sshhostname'] = lambda: "{user}@{hostname}" if "SSH_TTY" in ''${...} else $PROMPT_FIELDS['rootuser']()
      $PROMPT = '{gitstatus:{RESET}[{}{RESET}] }{sshhostname:{} }{BOLD_GREEN}{short_cwd}{RED}{last_return_code_if_nonzero: [{BOLD_INTENSE_RED}{}{RED}] }{RESET}{BOLD_BLUE}{RESET}> '
      $VI_MODE = True
      aliases['v'] = "nvim"
      aliases['c'] = "code"
      aliases['vim'] = "nvim"
      aliases['gpl'] = "git pull"
      aliases['gpf'] = "git push --force-with-lease --force-if-includes"
      aliases['gp'] = "git push"
      aliases['gd'] = "git diff"
      aliases['lg'] = "lazygit"
      aliases['gc'] = "git commit -v"
      # aliases['kb'] = "git commit -m \"\$(curl -s http://whatthecommit.com/index.txt)\""
      aliases['gs'] = "git status -v"
      aliases['gfc'] = "git fetch && git checkout"
      aliases['gl'] = "git log --graph"
      aliases['l'] = "exa -la --git"
      aliases['la'] = "exa -la --git"
      aliases['ls'] = "exa"
      aliases['ll'] = "exa -l --git"
      aliases['cat'] = "bat"
      aliases['p'] = "cd ~/proj"
      aliases['pd'] = "cd ~/proj/devsaur"

      # https://xon.sh/xonshrc.html?highlight=nix#use-the-nix-package-manager-with-xonsh
      import os.path
      if os.path.exists(f"{$HOME}/.nix-profile") and not __xonsh__.env.get("NIX_PATH"):
        $NIX_REMOTE="daemon"
        $NIX_USER_PROFILE_DIR="/nix/var/nix/profiles/per-user/" + $USER
        $NIX_PROFILES="/nix/var/nix/profiles/default " + $HOME + "/.nix-profile"
        $NIX_SSL_CERT_FILE="/etc/ssl/certs/ca-certificates.crt"
        $NIX_PATH="nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixpkgs:/nix/var/nix/profiles/per-user/root/channels"
        $PATH += [f"{$HOME}/.nix-profile/bin", "/nix/var/nix/profiles/default/bin"]

      xontrib load direnv 
      xontrib load fish_completer
    '';
    programs.vscode.userSettings."terminal.integrated.profiles.osx" = {
      xonsh = {
        path = "${xonsh}/bin/xonsh";
      };
    };
    programs.vscode.userSettings."terminal.integrated.defaultProfile.osx" = "xonsh";
    programs.tmux.extraConfig = ''
      set-option -g default-command "${xonsh}/bin/xonsh"
    '';
  };
}
