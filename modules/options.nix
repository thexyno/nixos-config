{ config, options, lib, home-manager, ... }:

with lib;
with lib.my;
{
  options = with types; {
    user = mkOpt attrs {};

    conf = let t = either str path; in {
      dir = mkOpt t
        (findFirst pathExists (toString ../.) [
          "/etc/nixos"
        ]);
      binDir     = mkOpt t "${config.conf.dir}/modules/bins";
      configDir  = mkOpt t "${config.conf.dir}/config";
      modulesDir = mkOpt t "${config.conf.dir}/modules";
      themesDir  = mkOpt t "${config.conf.modulesDir}/themes";
    };

  config = {
  };
}

