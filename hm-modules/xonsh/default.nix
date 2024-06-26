{ pkgs, config, lib, inputs, ... }:
let
  cfg = config.ragon.xonsh;
  xonsh =
    pkgs.unstable.xonsh.override {
      extraPackages = ps: [
        ps.numpy
        ps.pandas
        ps.requests
        (ps.buildPythonPackage {
          pname = "xonsh-direnv";
          version = "0.0.0";
          src = inputs.xonsh-direnv;
        })
        (ps.buildPythonPackage {
          pname = "xonsh-fish-completer";
          version = "0.0.0";
          format = "pyproject";
          src = inputs.xonsh-fish-completer;
          prePatch = ''
            pkgs.lib.substituteInPlace pyproject.toml --replace '"xonsh>=0.12.5"' ""
          '';
          patchPhase = "sed -i -e 's/^dependencies.*$/dependencies = []/' pyproject.toml";
          doCheck = false;
          propagatedBuildInputs = [
            ps.setuptools
          ];
        })
      ];
    };

  aliasesJson = pkgs.writeText "shell-aliases.json" (builtins.toJSON config.home.shellAliases);
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
      $PROMPT_FIELDS['sshhostname'] = lambda: f"{$PROMPT_FIELDS['user']}@{$PROMPT_FIELDS['hostname']}" if "SSH_TTY" in ''${...} else $PROMPT_FIELDS['rootuser']()
      $PROMPT = '{gitstatus:{RESET}[{}{RESET}] }{sshhostname:{} }{BOLD_GREEN}{short_cwd}{RED}{last_return_code_if_nonzero: [{BOLD_INTENSE_RED}{}{RED}] }{RESET}{BOLD_BLUE}{RESET}> '
      $VI_MODE = True


      with open("${aliasesJson}") as f_in:
        import json
        aliases |= json.load(f_in)

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
      # >>> mamba initialize >>>
      # !! Contents within this block are managed by 'mamba init' !!
      $MAMBA_EXE = "/etc/profiles/per-user/xyno/bin/micromamba"
      $MAMBA_ROOT_PREFIX = "/Users/xyno/micromamba"
      import sys as _sys
      from types import ModuleType as _ModuleType
      _mod = _ModuleType("xontrib.mamba",
                         'Autogenerated from $($MAMBA_EXE shell hook -s xonsh -p $MAMBA_ROOT_PREFIX)')
      __xonsh__.execer.exec($($MAMBA_EXE shell hook -s xonsh -p $MAMBA_ROOT_PREFIX),
                            glbs=_mod.__dict__,
                            filename='$($MAMBA_EXE shell hook -s xonsh -p $MAMBA_ROOT_PREFIX)')
      _sys.modules["xontrib.mamba"] = _mod
      del _sys, _mod, _ModuleType
      # <<< mamba initialize <<<
      execx($(mise activate xonsh))

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
