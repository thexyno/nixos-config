{ inputs, lib, pkgs, ... }:

with lib;
with lib.my;
let sys = "x86_64-linux";
in {
  mkHost = path: attrs @ { system ? sys, overlay, overlays, ... }:
    nixosSystem {
      inherit system;
      specialArgs = { inherit lib inputs system; };
      modules = [
        {
          nixpkgs.pkgs = pkgs;
          nixpkgs.overlays = [ overlay ] ++ overlays;
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
