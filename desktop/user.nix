
# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      (import "${builtins.fetchTarball https://github.com/rycee/home-manager/archive/release-20.09.tar.gz}/nixos")
    ];
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.philipp = {
    openssh.authorizedKeys.keys = 
    [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKGX53m9XKVk+7fkja+9nlULKw8lW5J0i8wlJ43/+JeH"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMvexOT9tnx2LfAE/OwfixfNc/esNAjZ+GDfLpY2iABk" ];
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    isNormalUser = true;
    shell = pkgs.zsh;
  };

  nix.allowedUsers = ["philipp" "root"];

  home-manager.users.philipp = {
    programs = {
      git = {
        enable = true;
	userName = "Philipp Hochkamp";
	userEmail = "me@phochkamp.de";
      };
      kitty = {
        enable = true;
        font = {
          package = pkgs.jetbrains-mono;
          name = "JetBrains Mono Medium";
        };
        settings = {
          "enable_audio_bell" = "false";
          "allow_remote_control" = "yes";
          "sync_to_monitor" = "yes";
          "background" = "#282828";
          "foreground" = "#ebdbb2";
          "background_opacity" = "1.0";
          "font_size" = "12";
        };
        keybindings = {
          "ctrl+minus" = "change_font_size all -2.0";
          "ctrl+plus"  = "change_font_size all +2.0";
        };
      
      };
      zsh = {
        enable = true;
        oh-my-zsh = {
          enable = true;
          plugins = ["git" "globalias"];
        };
        plugins = [
          {
            name = "zsh-vim-mode";
            src = builtins.fetchTarball {
              url = "https://github.com/softmoth/zsh-vim-mode/archive/master.tar.gz";
            };
          }
          {
            name = "zsh-syntax-highlighting";
            src = builtins.fetchTarball {
              url = "https://github.com/zsh-users/zsh-syntax-highlighting/archive/master.tar.gz";
            };
          }
          {
            name = "zsh-completions";
            src = builtins.fetchTarball {
              url = "https://github.com/zsh-users/zsh-completions/archive/master.tar.gz";
            };
          }
          {
            name = "agkozak-zsh-prompt";
            src = builtins.fetchTarball {
              url = "https://github.com/agkozak/agkozak-zsh-prompt/archive/master.tar.gz";
            };
          }


        ];

      shellAliases = {
          v = "nvim";
          vim = "nvim";
          gpl = "git pull";
          gp = "git push";
          gc = "git commit -v";
          kb = "git commit -a -m \"\$(curl -s http://whatthecommit.com/index.txt)\"";
          gs = "git status -v";
          gl = "git log --graph";
          l = "exa -la --git";
          la = "exa -la --git";
          ls = "exa";
          ll = "exa -l --git";
      };
      initExtra = ''
        AGKOZAK_MULTILINE=0
        AGKOZAK_PROMPT_CHAR=( ❯ ❯ "%F{red}N%f")
        autoload -Uz history-search-end

        zle -N history-beginning-search-backward-end history-search-end
        zle -N history-beginning-search-forward-end history-search-end
        
        bindkey -M vicmd '^[[A' history-beginning-search-backward-end \
                         '^[OA' history-beginning-search-backward-end \
                         '^[[B' history-beginning-search-forward-end \
                         '^[OB' history-beginning-search-forward-end
        bindkey -M viins '^[[A' history-beginning-search-backward-end \
                         '^[OA' history-beginning-search-backward-end \
                         '^[[B' history-beginning-search-forward-end \
                         '^[OB' history-beginning-search-forward-end
        
        hash go   2>/dev/null && export PATH=$PATH:$(go env GOPATH)/bin
        hash yarn 2>/dev/null && export PATH=$PATH:$HOME/.yarn/bin
        export PATH=$PATH:$HOME/scripts
        export PATH=$PATH:$HOME/.config/rofi/bins
        export PATH=$PATH:$HOME/.local/bin
        export PATH=$PATH:$HOME/flutter/flutter/bin
        hash kitty 2>/dev/null && alias ssh="kitty kitten ssh"
        hash helm 2>/dev/null && . <(helm completion zsh)
        hash kubectl 2>/dev/null && . <(kubectl completion zsh)
        export NNN_ARCHIVE="\\.(7z|a|ace|alz|arc|arj|bz|bz2|cab|cpio|deb|gz|jar|lha|lz|lzh|lzma|lzo|rar|rpm|rz|t7z|tar|tbz|tbz2|tgz|tlz|txz|tZ|tzo|war|xpi|xz|Z|zip)$"
        
        n ()
        {
            # Block nesting of nnn in subshells
            if [ -n $NNNLVL ] && [ "${NNNLVL:-0}" -ge 1 ]; then
                echo "nnn is already running"
                return
            fi
        
            export NNN_TMPFILE="$HOME/.config/nnn/.lastd"
        
            # Unmask ^Q (, ^V etc.) (if required, see `stty -a`) to Quit nnn
            # stty start undef
            # stty stop undef
            # stty lwrap undef
            # stty lnext undef
        
            nnn -d "$@"
        
            if [ -f "$NNN_TMPFILE" ]; then
                    . "$NNN_TMPFILE"
                    rm -f "$NNN_TMPFILE" > /dev/null
            fi
        }
        '';
      };


    };

  };
}

