{ config, pkgs, inputs, ... }: {
  programs.gnupg.agent.enable = true;
  programs.zsh.enable = true;
  environment.pathsToLink = [ "/share/zsh" ];
  services.nix-daemon.enable = true;
  nix.package = pkgs.nixVersions.stable;
  nix.settings.cores = 0; # use all cores
  nix.settings.max-jobs = 10; # use all cores
  nix.settings.auto-optimise-store = true;
  nix.distributedBuilds = true;
  nix.nixPath = [{ nixpkgs = "${inputs.nixpkgs-darwin}"; nixpkgs-master = "${inputs.nixpkgs-master}"; nixpkgs-nixos = "${inputs.nixpkgs}"; }];
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
      hostName = "192.168.65.7";
      sshKey = "/Users/ragon/.ssh/id_ed25519";
      publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUM4aG9teFlQZlk4bS9JQ2c2NVNWNU9Temp3eW1sNmxEMXhGNi9zWUxPQkY=";
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

