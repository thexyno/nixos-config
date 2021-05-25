{ inputs, lib, pkgs, ... }:

with lib;
with lib.my;
let 
  sys = "x86_64-linux";
  unstableOverlay = final: prev: {
    unstable = inputs.nixpkgs-master {
      system = sys;
      config.allowUnfree = true;
    };
  };
in {
  mkHost = path: attrs @ { system ? sys, ... }:
    nixosSystem {
      inherit system;
      specialArgs = { inherit lib inputs system; };
      modules = [
        {
          nixpkgs = {
            overlays = [ unstableOverlay ];
            pkgs = pkgs;
            config.allowUnfree = true;
          };
          networking.hostName = mkDefault (removeSuffix ".nix" (baseNameOf path));
        }
        (filterAttrs (n: v: !elem n [ "system" ]) attrs)
        ../.   # /default.nix
        (import path)
      ];
    };

  mapHosts = dir: attrs @ { system ? system, ... }:
    mapModules dir
      (hostPath: mkHost hostPath attrs);
}
