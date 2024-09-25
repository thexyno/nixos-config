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
         let carapace_completer = {|spans: list<string>|
             carapace $spans.0 nushell ...$spans
             | from json
             | if ($in | default [] | where value =~ '^-.*ERR$' | is-empty) { $in } else { null }
         }
         let external_completer = {|spans|
             let expanded_alias = scope aliases
             | where name == $spans.0
             | get -i 0.expansion
         
             let spans = if $expanded_alias != null {
                 $spans
                 | skip 1
                 | prepend ($expanded_alias | split row ' ' | take 1)
             } else {
                 $spans
             }
         
             match $spans.0 {
                 # carapace completions are incorrect for nu
                 # nu => $fish_completer
                 # fish completes commits and branch names in a nicer way
                 # git => $fish_completer
                 # carapace doesn't have completions for asdf
                 # asdf => $fish_completer
                 # use zoxide completions for zoxide commands
                 # __zoxide_z | __zoxide_zi => $zoxide_completer
                 _ => $carapace_completer
             } | do $in $spans
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
              completer: $external_completer # check 'carapace_completer' 
            }
          }
         } 
        $env.EDITOR = "hx"
        $env.VISUAL = "hx"
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
        alias ytl = yt-dlp -f "bv*+mergeall[vcodec=none]" --audio-multistreams
      '';
      shellAliases = {
        vi = "hx";
        vim = "hx";
        nano = "hx";
      };
    };
    programs.carapace.enable = true;
    programs.carapace.enableNushellIntegration = true;

    programs.starship = {
      enable = true;
      settings = {
        "add_newline" = true;
        "aws" = {
          "disabled" = true;
          "format" = " [aws](italic) [$symbol $profile $region]($style)";
          "style" = "bold blue";
          "symbol" = "▲ ";
        };
        "battery" = {
          "charging_symbol" = "[↑](italic bold green)";
          "discharging_symbol" = "↓";
          "display" = [
            {
              "style" = "italic bold red";
              "threshold" = 20;
            }
            {
              "style" = "italic dimmed bright-purple";
              "threshold" = 60;
            }
            {
              "style" = "italic dimmed yellow";
              "threshold" = 70;
            }
          ];
          "empty_symbol" = "▃";
          "format" = "[ $percentage $symbol]($style)";
          "full_symbol" = "█";
          "unknown_symbol" = "░";
        };
        "buf" = {
          "format" = " [buf](italic) [$symbol $version $buf_version]($style)";
          "symbol" = "■ ";
        };
        "c" = {
          "format" = " [$symbol($version(-$name))]($style)";
          "symbol" = "ℂ ";
        };
        "character" = {
          "error_symbol" = "[○](italic purple)";
          "format" = "$symbol ";
          "success_symbol" = "[◎](bold italic bright-yellow)";
          "vimcmd_replace_one_symbol" = "◌";
          "vimcmd_replace_symbol" = "□";
          "vimcmd_symbol" = "[■](italic dimmed green)";
          "vimcmd_visual_symbol" = "▼";
        };
        "cmd_duration" = {
          "format" = "[◄ $duration ](italic white)";
        };
        "conda" = {
          "format" = " conda [$symbol$environment]($style)";
          "symbol" = "◯ ";
        };
        "continuation_prompt" = "[▸▹ ](dimmed white)";
        "dart" = {
          "format" = " dart [$symbol($version )]($style)";
          "symbol" = "◁◅ ";
        };
        "deno" = {
          "format" = " [deno](italic) [∫ $version](green bold)";
          "version_format" = "\${raw}";
        };
        "directory" = {
          "format" = "[$path]($style)[$read_only]($read_only_style)";
          "home_symbol" = "⌂";
          "read_only" = " ◈";
          "repo_root_format" = "[$before_root_path]($before_repo_root_style)[$repo_root]($repo_root_style)[$path]($style)[$read_only]($read_only_style) [△](bold bright-blue)";
          "repo_root_style" = "bold blue";
          "style" = "italic blue";
          "truncation_length" = 2;
          "truncation_symbol" = "□ ";
          "use_os_path_sep" = true;
        };
        "docker_context" = {
          "format" = " docker [$symbol$context]($style)";
          "symbol" = "◧ ";
        };
        "elixir" = {
          "format" = " exs [$symbol $version OTP $otp_version ]($style)";
          "symbol" = "△ ";
        };
        "elm" = {
          "format" = " elm [$symbol($version )]($style)";
          "symbol" = "◩ ";
        };
        "env_var" = {
          "VIMSHELL" = {
            "format" = "[$env_value]($style)";
            "style" = "green italic";
          };
        };
        "fill" = {
          "symbol" = " ";
        };
        "format" = "($nix_shell$container$fill$git_metrics\n)$cmd_duration$hostname$localip$shlvl$shell$env_var$jobs$sudo$username$character";
        "git_branch" = {
          "format" = " [$branch(:$remote_branch)]($style)";
          "ignore_branches" = [
            "main"
            "master"
          ];
          "only_attached" = true;
          "style" = "italic bright-blue";
          "symbol" = "[△](bold italic bright-blue)";
          "truncation_length" = 11;
          "truncation_symbol" = "⋯";
        };
        "git_metrics" = {
          "added_style" = "italic dimmed green";
          "deleted_style" = "italic dimmed red";
          "disabled" = false;
          "format" = "([▴$added]($added_style))([▿$deleted]($deleted_style))";
          "ignore_submodules" = true;
        };
        "git_status" = {
          "ahead" = "[▴│[\${count}](bold white)│](italic green)";
          "behind" = "[▿│[\${count}](bold white)│](italic red)";
          "conflicted" = "[◪◦](italic bright-magenta)";
          "deleted" = "[✕](italic red)";
          "diverged" = "[◇ ▴┤[\${ahead_count}](regular white)│▿┤[\${behind_count}](regular white)│](italic bright-magenta)";
          "format" = "([⎪$ahead_behind$staged$modified$untracked$renamed$deleted$conflicted$stashed⎥]($style))";
          "modified" = "[●◦](italic yellow)";
          "renamed" = "[◎◦](italic bright-blue)";
          "staged" = "[▪┤[$count](bold white)│](italic bright-cyan)";
          "stashed" = "[◃◈](italic white)";
          "style" = "bold italic bright-blue";
          "untracked" = "[◌◦](italic bright-yellow)";
        };
        "golang" = {
          "format" = " go [$symbol($version )]($style)";
          "symbol" = "∩ ";
        };
        "haskell" = {
          "format" = " hs [$symbol($version )]($style)";
          "symbol" = "❯λ ";
        };
        "java" = {
          "format" = " java [\${symbol}(\${version} )]($style)";
          "symbol" = "∪ ";
        };
        "jobs" = {
          "format" = "[$symbol$number]($style) ";
          "style" = "white";
          "symbol" = "[▶](blue italic)";
        };
        "julia" = {
          "format" = " jl [$symbol($version )]($style)";
          "symbol" = "◎ ";
        };
        "localip" = {
          "disabled" = false;
          "format" = " ◯[$localipv4](bold magenta)";
          "ssh_only" = true;
        };
        "lua" = {
          "format" = " [lua](italic) [\${symbol}\${version}]($style)";
          "style" = "bold bright-yellow";
          "symbol" = "⨀ ";
          "version_format" = "\${raw}";
        };
        "memory_usage" = {
          "format" = " mem [\${ram}( \${swap})]($style)";
          "symbol" = "▪▫▪ ";
        };
        "nim" = {
          "format" = " nim [$symbol($version )]($style)";
          "symbol" = "▴▲▴ ";
        };
        "nix_shell" = {
          "format" = "[$symbol nix⎪$state⎪]($style) [$name](italic dimmed white)";
          "impure_msg" = "[⌽](bold dimmed red)";
          "pure_msg" = "[⌾](bold dimmed green)";
          "style" = "bold italic dimmed blue";
          "symbol" = "✶";
          "unknown_msg" = "[◌](bold dimmed ellow)";
        };
        "nodejs" = {
          "detect_extensions" = [
          ];
          "detect_files" = [
            "package-lock.json"
            "yarn.lock"
          ];
          "detect_folders" = [
            "node_modules"
          ];
          "format" = " [node](italic) [◫ ($version)](bold bright-green)";
          "version_format" = "\${raw}";
        };
        "package" = {
          "format" = " [pkg](italic dimmed) [$symbol$version]($style)";
          "style" = "dimmed yellow italic bold";
          "symbol" = "◨ ";
          "version_format" = "\${raw}";
        };
        "python" = {
          "format" = " [py](italic) [\${symbol}\${version}]($style)";
          "style" = "bold bright-yellow";
          "symbol" = "[⌉](bold bright-blue)⌊ ";
          "version_format" = "\${raw}";
        };
        "right_format" = "$singularity$kubernetes$directory$vcsh$fossil_branch$git_branch$git_commit$git_state$git_status$hg_branch$pijul_channel$docker_context$package$c$cmake$cobol$daml$dart$deno$dotnet$elixir$elm$erlang$fennel$golang$guix_shell$haskell$haxe$helm$java$julia$kotlin$gradle$lua$nim$nodejs$ocaml$opa$perl$php$pulumi$purescript$python$raku$rlang$red$ruby$rust$scala$solidity$swift$terraform$vlang$vagrant$zig$buf$conda$meson$spack$memory_usage$aws$gcloud$openstack$azure$crystal$custom$status$os$battery$time";
        "ruby" = {
          "format" = " [rb](italic) [\${symbol}\${version}]($style)";
          "style" = "bold red";
          "symbol" = "◆ ";
          "version_format" = "\${raw}";
        };
        "rust" = {
          "format" = " [rs](italic) [$symbol$version]($style)";
          "style" = "bold red";
          "symbol" = "⊃ ";
          "version_format" = "\${raw}";
        };
        "spack" = {
          "format" = " spack [$symbol$environment]($style)";
          "symbol" = "◇ ";
        };
        "sudo" = {
          "disabled" = false;
          "format" = "[$symbol]($style)";
          "style" = "bold italic bright-purple";
          "symbol" = "⋈┈";
        };
        "swift" = {
          "format" = " [sw](italic) [\${symbol}\${version}]($style)";
          "style" = "bold bright-red";
          "symbol" = "◁ ";
          "version_format" = "\${raw}";
        };
        "time" = {
          "disabled" = false;
          "format" = "[ $time]($style)";
          "style" = "italic dimmed white";
          "time_format" = "%R";
          "utc_time_offset" = "local";
        };
        "username" = {
          "disabled" = false;
          "format" = "[⭘ $user]($style) ";
          "show_always" = false;
          "style_root" = "purple bold italic";
          "style_user" = "bright-yellow bold italic";
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
