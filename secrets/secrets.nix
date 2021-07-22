let
  pubkeys = import ../data/pubkeys.nix;
in
{
  "smb.age".publicKeys = pubkeys.ragon.computers;
  "cloudflareAcme.age".publicKeys = pubkeys.ragon.computers;
  "nextshot.age".publicKeys = pubkeys.ragon.computers;
  "pulseLaunch.age".publicKeys = pubkeys.ragon.computers;
  "rootPasswd.age".publicKeys = pubkeys.ragon.computers;
  "ragonPasswd.age".publicKeys = pubkeys.ragon.computers;
  "gitlabInitialRootPassword.age".publicKeys = pubkeys.ragon.computers;
  "gitlabSecretFile.age".publicKeys = pubkeys.ragon.computers;
  "gitlabDBFile.age".publicKeys = pubkeys.ragon.computers;
  "gitlabOTPFile.age".publicKeys = pubkeys.ragon.computers;
  "gitlabJWSFile.age".publicKeys = pubkeys.ragon.computers;
  "nextcloudAdminPass.age".publicKeys = pubkeys.ragon.computers;
  "wireguardwormhole.age".publicKeys = pubkeys.ragon.hosts.wormhole;
}
