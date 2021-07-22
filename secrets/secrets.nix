let
  pubkeys = import ../data/pubkeys.nix;
in
{
  "cloudflareAcme.age".publicKeys = pubkeys.ragon.server;
  "nextshot.age".publicKeys = pubkeys.ragon.client;
  "pulseLaunch.age".publicKeys = pubkeys.ragon.client;
  "rootPasswd.age".publicKeys = pubkeys.ragon.computers;
  "ragonPasswd.age".publicKeys = pubkeys.ragon.computers;
  "gitlabInitialRootPassword.age".publicKeys = pubkeys.ragon.host "picard";
  "gitlabSecretFile.age".publicKeys = pubkeys.ragon.host "picard";
  "gitlabDBFile.age".publicKeys = pubkeys.ragon.host "picard";
  "gitlabOTPFile.age".publicKeys = pubkeys.ragon.host "picard";
  "gitlabJWSFile.age".publicKeys = pubkeys.ragon.host "picard";
  "nextcloudAdminPass.age".publicKeys = pubkeys.ragon.host "picard";
  "wireguardwormhole.age".publicKeys = pubkeys.ragon.host "wormhole";
}
