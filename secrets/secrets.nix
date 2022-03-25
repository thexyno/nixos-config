let
  pubkeys = import ../data/pubkeys.nix;
in
{
  "cloudflareAcme.age".publicKeys = pubkeys.ragon.server;
  "nextshot.age".publicKeys = pubkeys.ragon.client;
  "pulseLaunch.age".publicKeys = pubkeys.ragon.client;
  "rootPasswd.age".publicKeys = pubkeys.ragon.computers;
  "wpa_supplicant.age".publicKeys = pubkeys.ragon.computers;
  "ragonPasswd.age".publicKeys = pubkeys.ragon.computers;
  "tailscaleKey.age".publicKeys = pubkeys.ragon.computers;
  "paperlessAdminPW.age".publicKeys = pubkeys.ragon.host "ds9";
  "ds9rcloneConfig.age".publicKeys = pubkeys.ragon.host "ds9";
  "ds9resticPassword.age".publicKeys = pubkeys.ragon.host "ds9";
  "hedgedocSecret.age".publicKeys = pubkeys.ragon.host "picard";
  "gitlabInitialRootPassword.age".publicKeys = pubkeys.ragon.host "picard";
  "gitlabSecretFile.age".publicKeys = pubkeys.ragon.host "picard";
  "gitlabDBFile.age".publicKeys = pubkeys.ragon.host "picard";
  "gitlabOTPFile.age".publicKeys = pubkeys.ragon.host "picard";
  "gitlabJWSFile.age".publicKeys = pubkeys.ragon.host "picard";
  "nextcloudAdminPass.age".publicKeys = pubkeys.ragon.host "picard";
}
