{ pkgs, inputs, lib, ... }:
with lib;
with lib.my;
{
  networking.hostName = "daedalus";

  users.users.ragon = {
    name = "ragon";
    home = "/Users/ragon";
  };

  homebrew = {
    enable = true;
    autoUpdate = true;
    casks = [ "hammerspoon" "amethyst" "android-platform-tools" "alfred" "ukelele" "homebrew/cask-drivers/zsa-wally" "lens" "logseq" ];
    masApps = { # Install Mac App Store apps (install them manually and then do `mas list` to get the id)
      "AdGuard for Safari" =  1440147259;
      "Xcode" =  497799835;
      "Home Assistant" =  1099568401;
      "WireGuard" =  1451685025;
      "UTM" =  1538878817;
      "Bitwarden" =  1352778147;
      "Shareful" =  1522267256;
      "app.seashore" = 1448648921;
      "Tailscale" =  1475387142;
    };
  };

  programs.gnupg.agent.enable = true;
  home-manager.users.ragon = { pkgs, lib, inputs, config, ... }: {
    home.file.".hammerspoon/init.lua".source = ./hammerspoon.lua;

    programs.home-manager.enable = true;
    home.stateVersion = "21.11";

    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      PATH = "$PATH:/etc/profiles/per-user/ragon/bin/:$HOME/development/flutter/bin:/Applications/Android Studio.app/Contents/bin/:/Applications/Docker.app/Contents/Resources/bin:/Applications/Android Studio.app/Contents/jre/Contents/Home/bin:$HOME/.nix-profile/bin:/nix/var/nix/profiles/system/sw/bin:/nix/var/nix/profiles/per-user/ragon/home-manager/home-path/bin/";
      JAVA_HOME = "/Applications/Android Studio.app/Contents/jre/Contents/Home/";
    };
    home.packages = with pkgs; [
      terraform-ls
      terraform

      #tectonic
      pandoc

      yabai

      google-cloud-sdk
    ];

    home.activation = {
      aliasApplications =
        let
          apps = pkgs.buildEnv {
            name = "home-manager-applications";
            paths = config.home.packages;
            pathsToLink = "/Applications";
          };
        in
        lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          # Install MacOS applications to the user environment.
          HM_APPS="$HOME/Applications/Home Manager Apps"

          # Reset current state
          [ -e "$HM_APPS" ] && $DRY_RUN_CMD rm -r "$HM_APPS"
          $DRY_RUN_CMD mkdir -p "$HM_APPS"

          # .app dirs need to be actual directories for Finder to detect them as Apps.
          # The files inside them can be symlinks though.
          $DRY_RUN_CMD cp --recursive --symbolic-link --no-preserve=mode -H ${apps}/Applications/* "$HM_APPS" || true # can fail if no apps exist
          # Modes need to be stripped because otherwise the dirs wouldn't have +w,
          # preventing us from deleting them again
          # In the env of Apps we build, the .apps are symlinks. We pass all of them as
          # arguments to cp and make it dereference those using -H
        '';
    };

  };

}
