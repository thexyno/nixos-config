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

  mkNode = path: attrs @ { ... }:
    let
      bnpath = baseNameOf path;
      system = builtins.elemAt (builtins.split "\n" (builtins.readFile "${path}/system")) 0; # i didnt find a remove whitespace function
    in
    (if (builtins.pathExists "${path}/deployment.nix") then {
      ${bnpath} = {
        hostname = mkDefault "${bnpath}.hailsatan.eu";
        profiles.system = {
          path = inputs.deploy-rs.lib.${system}.activate.nixos attrs.out.${baseNameOf path};
        };
      } // (import "${path}/deployment.nix");
    } else { });

  mapNodes = dir: attrs @ { ... }:
    foldl (a: b: a // b) { } (mapModules' dir
      (hostPath: mkNode hostPath attrs));




}
