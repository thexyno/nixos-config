{ config, pkgs, inputs, ... }: {
  programs.zsh.enable = true;
  environment.pathsToLink = [ "/share/zsh" ];
  services.nix-daemon.enable = true;
  nix.settings.cores = 0; # use all cores
  nix.settings.max-jobs = 10; # use all cores
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  security.pam.enableSudoTouchIdAuth = true;
  programs.zsh.shellInit = ''
    eval "$(/opt/homebrew/bin/brew shellenv)"
  '';
  environment.systemPath = [ "/opt/homebrew/bin" "/opt/homebrew/sbin" ];
  #nix.settings.auto-optimise-store = true;
  nix.distributedBuilds = true;
  nix.nixPath = [{ nixpkgs = "${inputs.nixpkgs-darwin.outPath}"; nixpkgs-master = "${inputs.nixpkgs-master.outPath}"; nixpkgs-nixos = "${inputs.nixpkgs.outPath}"; }];
  nix.buildMachines = [{
    systems = [ "x86_64-linux" ];
    supportedFeatures = [ "kvm" "big-parallel" ];
    sshUser = "ragon";
    maxJobs = 12;
    hostName = "ds9";
    sshKey = "/Users/xyno/.ssh/id_ed25519";
    publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUorQkJYdWZYQUpoeVVIVmZocWxrOFk0ekVLSmJLWGdKUXZzZEU0ODJscFYgcm9vdEBpc28K";
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
    dock.expose-animation-duration = 0.01;
    finder.AppleShowAllExtensions = true;
    finder.FXEnableExtensionChangeWarning = false;
    loginwindow.GuestEnabled = false;
  };
}

