{ options, config, inputs, lib, pkgs, ... }:

with builtins;
with lib;
with lib.my;
let
  secretsDir = "${toString ../../secrets}";
  secretsFile = "${secretsDir}/secrets.nix";
  cfg = config.ragon.agenix;
in
{
  options.ragon.agenix = {
    enable = mkBoolOpt true;
    secrets = mkOption {
      type = types.attrs;
      default = { };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [ inputs.agenix.packages.${pkgs.system}.default ];
    # Set passwords
    users.users.root.passwordFile = config.age.secrets.rootPasswd.path;
    age.identityPaths =
      [
        "/persistent/etc/ssh/ssh_host_ed25519_key"
      ];
    age.secrets = mapAttrs (name: obj: ({ file = "${secretsDir}/${name}.age"; } // obj))
      (cfg.secrets //
        {
          rootPasswd = { };
        }
      );
    assertions = [
      { assertion = (pathExists secretsFile); message = "${secretsFile} does not exist"; }
    ];
  };
}
