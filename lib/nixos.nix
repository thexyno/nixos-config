{ inputs, lib, pkgsBySystem, ... }:

with lib;
with lib.my;
{
  mkHost = path: attrs @ { ... }:
  let 
    system = builtins.readFile "${path}/system";
    realpkgs = pkgsBySystem.${system};
  in
    nixosSystem {
      inherit system;
      specialArgs = { inherit lib inputs system; };
      modules = [
        {
          nixpkgs.pkgs = realpkgs;
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
