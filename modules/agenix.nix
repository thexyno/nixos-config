{ options, config, inputs, lib, pkgs, ... }:

with builtins;
with lib;
with lib.my;
let
  inherit (inputs) agenix;
  secretsDir = "${toString ../secrets}";
  secretsFile = "${secretsDir}/secrets.nix";
in
{
  imports = [ agenix.nixosModules.age ];
  environment.systemPackages = [ agenix.defaultPackage.${pkgs.system} ];

  age = {
    secrets =
      if pathExists secretsFile
      then
        mapAttrs'
          (n: _: nameValuePair (removeSuffix ".age" n) {
            file = "${secretsDir}/${n}";
            owner = if (hasInfix "root" n) then mkDefault "root" else mkDefault config.ragon.user.username;
          })
          (import secretsFile)
      else { };
    sshKeyPaths =
      [
        "/persistent/etc/ssh/ssh_host_rsa_key"
        "/persistent/etc/ssh/ssh_host_ed25519_key"
      ];
  };
}
