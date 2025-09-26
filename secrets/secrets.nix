let
  pubkeys = import ../data/pubkeys.nix;
in
{
  "ionos.age".publicKeys = pubkeys.ragon.server;
  "nextshot.age".publicKeys = pubkeys.ragon.client;
  "pulseLaunch.age".publicKeys = pubkeys.ragon.client;
  "rootPasswd.age".publicKeys = pubkeys.ragon.computers;
  "msmtprc.age".publicKeys = pubkeys.ragon.computers;
  "smtpPassword.age".publicKeys = pubkeys.ragon.computers;
  "aliases.age".publicKeys = pubkeys.ragon.computers;
  "wpa_supplicant.age".publicKeys = pubkeys.ragon.computers;
  "ragonPasswd.age".publicKeys = pubkeys.ragon.computers;
  "tailscaleKey.age".publicKeys = pubkeys.ragon.computers;
  "paperlessAdminPW.age".publicKeys = pubkeys.ragon.host "ds9";
  "borgmaticEncryptionKey.age".publicKeys = pubkeys.ragon.host "ds9";
  "photoprismEnv.age".publicKeys = pubkeys.ragon.host "ds9";
  "ds9OffsiteBackupSSH.age".publicKeys = pubkeys.ragon.host "ds9";
  "ds9SyncoidHealthCheckUrl.age".publicKeys = pubkeys.ragon.host "ds9";
  "ds9DynDns.age".publicKeys = pubkeys.ragon.host "ds9";
  "ds9SnipeIt.age".publicKeys = pubkeys.ragon.host "ds9";
  "ds9GristEnv.age".publicKeys = pubkeys.ragon.host "ds9";
  "ds9PostgresEnv.age".publicKeys = pubkeys.ragon.host "ds9";
  "ds9ImmichEnv.age".publicKeys = pubkeys.ragon.host "ds9";
  "ds9AuthentikEnv.age".publicKeys = pubkeys.ragon.host "ds9";
  "ds9WoodpeckerEnv.age".publicKeys = pubkeys.ragon.host "ds9";
  "ds9AtticEnv.age".publicKeys = pubkeys.ragon.host "ds9";
  "ds9WoodpeckerAgentSecretEnv.age".publicKeys = pubkeys.ragon.host "ds9";
  "ds9PartDbEnv.age".publicKeys = pubkeys.ragon.host "ds9";
  "ds9AuthentikLdapEnv.age".publicKeys = pubkeys.ragon.host "ds9";
  "ds9PostgresExporterEnv.age".publicKeys = pubkeys.ragon.host "ds9";
  "gatebridgeHostKeys.age".publicKeys = pubkeys.ragon.server;
  "plausibleAdminPw.age".publicKeys = pubkeys.ragon.host "picard";
  "plausibleGoogleClientId.age".publicKeys = pubkeys.ragon.host "picard";
  "plausibleGoogleClientSecret.age".publicKeys = pubkeys.ragon.host "picard";
  "plausibleReleaseCookie.age".publicKeys = pubkeys.ragon.host "picard";
  "plausibleSecretKeybase.age".publicKeys = pubkeys.ragon.host "picard";
  "hedgedocSecret.age".publicKeys = pubkeys.ragon.host "picard";
  "mailmoverConf.age".publicKeys = pubkeys.ragon.host "picard";
  "matrixSecrets.age".publicKeys = pubkeys.ragon.host "picard";
  "gitlabInitialRootPassword.age".publicKeys = pubkeys.ragon.host "picard";
  "gitlabSecretFile.age".publicKeys = pubkeys.ragon.host "picard";
  "gitlabDBFile.age".publicKeys = pubkeys.ragon.host "picard";
  "gitlabOTPFile.age".publicKeys = pubkeys.ragon.host "picard";
  "gitlabJWSFile.age".publicKeys = pubkeys.ragon.host "picard";
  "nextcloudAdminPass.age".publicKeys = pubkeys.ragon.host "picard";
  "picardSharenoteEnv.age".publicKeys = pubkeys.ragon.host "picard";
  "picardResticSSHKey.age".publicKeys = pubkeys.ragon.host "picard";
  "picardSlidingSyncSecret.age".publicKeys = pubkeys.ragon.host "picard";
  "picardCalCom.age".publicKeys = pubkeys.ragon.host "picard";
  "picardResticPassword.age".publicKeys = pubkeys.ragon.host "picard";
  "picardResticHealthCheckUrl.age".publicKeys = pubkeys.ragon.host "picard";
  "desec.age".publicKeys = pubkeys.ragon.computers;
  "autheliaStorageEncryption.age".publicKeys = pubkeys.ragon.host "picard";
  "autheliaSessionSecret.age".publicKeys = pubkeys.ragon.host "picard";
  "autheliaOidcIssuerPrivateKey.age".publicKeys = pubkeys.ragon.host "picard";
  "autheliaOidcHmacSecret.age".publicKeys = pubkeys.ragon.host "picard";
  "autheliaJwtSecret.age".publicKeys = pubkeys.ragon.host "picard";
  "autheliaEmail.age".publicKeys = pubkeys.ragon.host "picard";
  "autheliaHedgedoc.age".publicKeys = pubkeys.ragon.host "picard";
  "smbSecrets.age".publicKeys = pubkeys.ragon.computers;

  # ovpn
  "ovpnDe.age".publicKeys = pubkeys.ragon.host "picard";
  "ovpnNl.age".publicKeys = pubkeys.ragon.host "picard";
  "ovpnTu.age".publicKeys = pubkeys.ragon.host "picard";
  "ovpnCrt1.age".publicKeys = pubkeys.ragon.host "picard";
  "ovpnPw1.age".publicKeys = pubkeys.ragon.host "picard";
  "ovpnPw2.age".publicKeys = pubkeys.ragon.host "picard";
  "ovpnScript.age".publicKeys = pubkeys.ragon.host "picard";

}
