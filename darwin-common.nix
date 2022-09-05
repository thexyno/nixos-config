{ config, pkgs, ... }: {
  programs.gnupg.agent.enable = true;
  programs.zsh.enable = true;
  environment.pathsToLink = [ "/share/zsh" ];
  services.nix-daemon.enable = true;
  nix.package = pkgs.nixFlakes;
  nix.settings.cores = 0; # use all cores
  nix.settings.max-jobs = 10; # use all cores
  nix.distributedBuilds = true;
  nix.buildMachines = [{
    systems = [ "x86_64-linux" ];
    supportedFeatures = [ "kvm" "big-parallel" ];
    sshUser = "ragon";
    maxJobs = 12;
    hostName = "ds9";
    sshKey = "/Users/ragon/.ssh/id_ed25519";
    publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUorQkJYdWZYQUpoeVVIVmZocWxrOFk0ekVLSmJLWGdKUXZzZEU0ODJscFYgcm9vdEBpc28K";
  }
    {
      systems = [ "aarch64-linux" "x86_64-linux" ];
      speedFactor = 2;
      supportedFeatures = [ "kvm" "big-parallel" ];
      sshUser = "ragon";
      maxJobs = 8;
      hostName = "192.168.64.7";
      sshKey = "/Users/ragon/.ssh/id_ed25519";
      publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUJMMm94ZEtha01Ka05iTExZK2xnNFkzd25jWnJwVE1sVHRBUWdsazVkVVEgcm9vdEBkYWVkYWx1c3ZtCg==";
    }];
  nix.extraOptions = ''
    builders-use-substitutes = true
  '';

  system.defaults = {
    NSGlobalDomain.AppleShowAllExtensions = true;
    NSGlobalDomain.InitialKeyRepeat = 25;
    NSGlobalDomain.KeyRepeat = 4;
    NSGlobalDomain.NSNavPanelExpandedStateForSaveMode = true;
    NSGlobalDomain.PMPrintingExpandedStateForPrint = true;
    NSGlobalDomain."com.apple.mouse.tapBehavior" = 1;
    NSGlobalDomain."com.apple.trackpad.trackpadCornerClickBehavior" = 1;
    dock.autohide = true;
    dock.mru-spaces = false;
    dock.show-recents = false;
    dock.static-only = true;
    finder.AppleShowAllExtensions = true;
    finder.FXEnableExtensionChangeWarning = false;
    loginwindow.GuestEnabled = false;
  };
}

