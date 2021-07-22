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
        # "<name of secret file>" = "<owner of secret file>";
      };
    };

  }
  config = mkIf cfg.enable {
    environment.systemPackages = [ agenix.defaultPackage.${pkgs.system} ];
    # Set passwords
    users.users.root.passwordFile = if (hasAttrByPath ["age" "secrets" "rootPasswd"] config) then config.age.secrets.rootPasswd.path else null;
    age.sshKeyPaths =
      [
        "/persistent/etc/ssh/ssh_host_rsa_key"
        "/persistent/etc/ssh/ssh_host_ed25519_key"
      ];
    age.secrets = mapAttrs (name: owner: { file = "${secretsDir}/${name}"; owner = owner;})
    assert assertMsg (pathExists secretsFile) "${secretsFile} does not exist";
  };
}
