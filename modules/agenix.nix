{ options, config, inputs, lib, pkgs, ... }:

with builtins;
with lib;
with lib.my;
let
  inherit (inputs) agenix;
  secretsDir = "${toString ../secrets}";
  secretsFile = "${secretsDir}/secrets.nix";
  cfg = config.ragon.agenix;
in
{
  imports = [ agenix.nixosModules.age ];
  options.ragon.agenix = {
    enable = mkBoolOpt true;
    secrets = mkOption {
      type = types.attrs;
      default = {
        rootPasswd = {};
        ragonPasswd = {};
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [ agenix.defaultPackage.${pkgs.system} ];
    # Set passwords
    users.users.root.passwordFile = config.age.secrets.rootPasswd.path;
    age.sshKeyPaths =
      [
        "/persistent/etc/ssh/ssh_host_rsa_key"
        "/persistent/etc/ssh/ssh_host_ed25519_key"
      ];
    age.secrets = traceVal (mapAttrs (name: obj: ({ file = "${secretsDir}/${name}.age"; } // obj)));
    assert assertMsg (pathExists secretsFile) "${secretsFile} does not exist";
  };
}
