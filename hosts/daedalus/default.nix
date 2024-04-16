{ pkgs, inputs, lib, ... }:
with lib;
with lib.my;
{

  users.users.xyno = {
    name = "xyno";
    home = "/Users/xyno";
  };

  homebrew = {
    enable = true;
    taps = [
      "cormacrelf/tap" # dark-notify
      "leoafarias/fvm" # flutter version manager
    ];
    brews = [
      "cormacrelf/tap/dark-notify"
      "lima"
      "docker" # docker cli
      "docker-compose"
      "leoafarias/fvm/fvm" # flutter version manager
      "cocoapods" # flutter/other ios shit

      "borgbackup" # time machine can eat my ass
    ];
    casks = [
      "plexamp"
      "vorta" # (borgbackup GUI) time machine can eat my ass
      "grandperspective"
      "xquartz"
      "hammerspoon"
      "kicad"
      "android-platform-tools"
      "nheko"
      "raycast"
      "ukelele"
      #      "homebrew/cask-drivers/zsa-wally"
      "thunderbird"
      "balenaetcher"
      "audacity"
      "openlens"
      "ferdium"
      "discord"
      "vlc"
      "rectangle"
      "floorp"
      "space-capsule"
      "iterm2"
      "signal"
      "eqmac"
      "syncthing"
      "android-studio"
      "temurin"
      "whisky"
      "dbeaver-community"

      "qutebrowser" # rly want to switch to it
      "dmenu-mac"

    ];
    #masApps = {
    #  # Install Mac App Store apps (install them manually and then do `mas list` to get the id)
    #  "AdGuard for Safari" = 1440147259;
    #  "Xcode" = 497799835;
    #  "Home as Assistant" = 1099568401;
    #  "WireGuard" = 1451685025;
    #  "UTM" = 1538878817;
    #  "Bitwarden" = 1352778147;
    #  "Shareful" = 1522267256;
    #  "app.seashore" = 1448648921;
    #  "Tailscale" = 1475387142;
    #};
  };

  environment.pathsToLink = [ "/share/fish" ];

  #ragon.services.borgmatic =
  #  let
  #    tmMountPath = "/tmp/timeMachineSnapshotForBorg";
  #  in
  #  {
  #    enable = false;
  #    configurations."daedalus-ds9" = {
  #      source_directories = [
  #        # tmMountPath
  #        "/Users/ragon"
  #      ];
  #      exclude_if_present = [ ".nobackup" ];
  #      repositories = [
  #        { path = "ssh://ragon@ds9/backups/daedalus/borgmatic"; label = "ds9"; }
  #        { path = "ssh://root@gatebridge/media/backup/daedalus"; label = "gatebridge"; }
  #      ];
  #      encryption_passcommand = pkgs.writeShellScript "getBorgmaticPw" ''security find-generic-password -a daedalus -s borgmaticKey -g 2>&1 | grep -E 'password' | sed 's/^.*"\(.*\)"$/\1/g' '';
  #      compression = "auto,zstd,10";
  #      #ssh_command = "ssh -o GlobalKnownHostsFile=${config.age.secrets.gatebridgeHostKeys.path} -i ${config.age.secrets.picardResticSSHKey.path}";
  #      keep_hourly = 24;
  #      keep_daily = 7;
  #      keep_weekly = 4;
  #      keep_monthly = 12;
  #      keep_yearly = 10;
  #      #        before_backup = [
  #      #          (pkgs.writeShellScript
  #      #            "apfsSnapshot"
  #      #            ''
  #      #              tmutil localsnapshot
  #      #              SNAPSHOT=$(tmutil listlocalsnapshots / | grep TimeMachine | tail -n 1)
  #      #              mkdir -p "${tmMountPath}"
  #      #              mount_apfs -s $SNAPSHOT /System/Volumes/Data "${tmMountPath}"
  #      #            '')
  #      #        ];
  #      #        after_backup = [
  #      #          (pkgs.writeShellScript
  #      #            "apfsSnapshotUnmount"
  #      #            ''
  #      #              diskutil unmount "${tmMountPath}"
  #      #              SNAPSHOT=$(tmutil listlocalsnapshots / | grep TimeMachine | tail -n 1)
  #      #              tmutil deletelocalsnapshots $(echo $SNAPSHOT | sed 's/com\.apple\.TimeMachine\.\(.*\)\.local/\1/g')
  #      #            '')
  #      #        ];
  #      #        on_error = [
  #      #
  #      #          (pkgs.writeShellScript
  #      #            "apfsSnapshotUnmountError"
  #      #            ''
  #      #              diskutil unmount "${tmMountPath}"
  #      #            '')
  #      #        ];
  #    };

  #  };

  home-manager.users.xyno = { pkgs, lib, inputs, config, ... }:
    {
      imports = [
        ../../hm-modules/nvim
        ../../hm-modules/tmux
        ../../hm-modules/vscode
        ../../hm-modules/xonsh
        ../../hm-modules/cli.nix
        ../../hm-modules/files.nix
      ];

      home.file.".hammerspoon/init.lua".source =
        let
          notmuchMails = pkgs.writeScript "notmuch-get-mail-count" ''
            #!/usr/bin/env zsh
             printf "I%s F%s W%s" $(notmuch search tag:inbox | wc -l) $(notmuch search tag:follow-up | wc -l)  $(notmuch search tag:waiting | wc -l)
          '';
        in
        pkgs.substituteAll {
          src = ./hammerspoon.lua; inherit notmuchMails;
        };
      home.file.".hammerspoon/Spoons/MiroWindowsManager.spoon".source = "${inputs.miro}/MiroWindowsManager.spoon";

      ragon.vscode.enable = true;
      ragon.xonsh.enable = true;

      programs.home-manager.enable = true;
      home.stateVersion = "23.11";

      #home.shellAliases = {
      #  v = lib.mkForce "emacsclient -t";
      #  vv = lib.mkForce "emacsclient -c";
      #};
      home.sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
        COLORTERM = "truecolor"; # emacs tty fix
      };
      home.packages = with pkgs; [
        mosh

        pandoc
        tectonic

        micromamba

        bitwarden-cli
        rustup
        ffmpeg
      ];

    };

}
