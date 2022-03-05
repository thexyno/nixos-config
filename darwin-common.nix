{config, pkgs, ...}: {
  programs.gnupg.agent.enable = true;
  services.nix-daemon.enable = true;
  nix.package = pkgs.nixFlakes;
  nix.buildCores = 0; # use all cores
  nix.maxJobs = 10; # use all cores
  nix.distributedBuilds = true;
  nix.buildMachines = [ {
    systems = ["x86_64-linux"];
    sshUser = "ragon";
    hostName = "ds9";
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

