# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      (import "${builtins.fetchTarball https://github.com/nix-community/home-manager/archive/release-20.09.tar.gz}/nixos")
    ];
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.philipp = {
    openssh.authorizedKeys.keys =
      [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKGX53m9XKVk+7fkja+9nlULKw8lW5J0i8wlJ43/+JeH"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMvexOT9tnx2LfAE/OwfixfNc/esNAjZ+GDfLpY2iABk"
      ];
    extraGroups = [ "wheel" "libvirtd" "tty" "audio" "dialout" "kvm" "input" ]; # Enable ‘sudo’ for the user.
    isNormalUser = true;
    shell = pkgs.zsh;
  };

  nix.allowedUsers = [ "philipp" "root" ];

  home-manager.users.philipp = {
    xdg.dataFile."nvim/coc-settings.json".source = ../programs/nvim/coc-settings.json;
    programs = {
      # neovim = (import ./nvim/default.nix { pkgs = pkgs; });
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
          "ctrl+plus" = "change_font_size all +2.0";
        };

      };
      zsh = {
        enable = true;
        oh-my-zsh = {
          enable = true;
          plugins = [ "git" "globalias" ];
        };
        plugins = [
          {
            name = "zsh-vim-mode";
            src = pkgs.fetchFromGitHub {
    owner = "softmoth";
    repo = "zsh-vim-mode";
    rev = "e5bf1aa6aab354007c0e041ff3f0fd091634e77b";
    sha256 = "0l5md3ra4a99x2snydmfwix1jpls7dsyhxaz552pppx7wslm44fg";
    fetchSubmodules = true;
  };
          }
          {
            name = "zsh-syntax-highlighting";
            src = pkgs.fetchFromGitHub {
    owner = "zsh-users";
    repo = "zsh-syntax-highlighting";
    rev = "e8517244f7d2ae4f9d979faf94608d6e4a74a73e";
    sha256 = "1dd1l4g5hkx1pnl1dw4h8ignjhigrvkkcravfkifdl2zf3slyny7";
    fetchSubmodules = true;
  };
          }
          {
            name = "zsh-completions";
            src = pkgs.fetchFromGitHub {
    owner = "zsh-users";
    repo = "zsh-completions";
    rev = "aa98bc593fee3fbdaf1acedc42a142f3c4134079";
    sha256 = "11q3f3nm0b13xhim5r3h2vpf76g97w811f30kl0a3w5i57jkc5vq";
    fetchSubmodules = true;
  };
          }
          {
            name = "agkozak-zsh-prompt";
            src = pkgs.fetchFromGitHub {
    owner = "agkozak";
    repo = "agkozak-zsh-prompt";
    rev = "b6106d95fb9a006c7f9fd6cdc7c0cbd2fe51365a";
    sha256 = "04df8rp4sig41ivi06sb1c121f4hm6bxfvgqi0xy5nb1rbxlnd2m";
    fetchSubmodules = true;
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
