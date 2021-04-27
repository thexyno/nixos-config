{ options, config, inputs, lib, pkgs, ... }:

with builtins;
with lib;
with lib.my;
let inherit (inputs) agenix;
    secretsDir = "${toString ../secrets}";
    secretsFile = "${secretsDir}/secrets.nix";
in {
  imports = [ agenix.nixosModules.age ];
  environment.systemPackages = [ agenix.defaultPackage.x86_64-linux ];

  age = {
    secrets =
      if pathExists secretsFile
      then mapAttrs' (n: _: nameValuePair (removeSuffix ".age" n) {
        file = "${secretsDir}/${n}";
        owner = mkDefault config.ragon.user.username;
      }) (import secretsFile)
      else {};
    sshKeyPaths =
      options.age.sshKeyPaths.default ++ (filter pathExists [
        "/home/${config.ragon.user.username}/.ssh/id_ed25519"
        "/home/${config.ragon.user.username}/.ssh/id_rsa"
      ]);
  };
}

