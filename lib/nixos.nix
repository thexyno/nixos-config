{ inputs, lib, pkgsBySystem, ... }:

with lib;
with lib.my;
{
  mkHost = path: attrs @ { ... }:
  let 
    system = builtins.elemAt (builtins.split "\n" (builtins.readFile "${path}/system")) 0; # i didnt find a remove whitespace function
    pkgs = pkgsBySystem.${system};
  in
    nixosSystem {
      inherit system;
      specialArgs = { inherit lib inputs system; };
      modules = [
        {
          nixpkgs.pkgs = pkgs;
          networking.hostName = mkDefault (removeSuffix ".nix" (baseNameOf path));
        }
        (filterAttrs (n: v: !elem n [ "system" ]) attrs)
        ../. # /default.nix
        (import path)
      ];
    };

  mapHosts = dir: attrs @ { ... }:
    mapModules dir
      (hostPath: mkHost hostPath attrs);
}
