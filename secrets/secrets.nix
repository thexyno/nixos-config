let
  pubkeys = import ../data/pubkeys.nix;
in
{
  "smb.age".publicKeys = pubkeys.ragon.computers;
  "nextshot.age".publicKeys = pubkeys.ragon.computers;
  "rootPasswd.age".publicKeys = pubkeys.ragon.computers;
  "rootRagonpasswd.age".publicKeys = pubkeys.ragon.computers;
}
