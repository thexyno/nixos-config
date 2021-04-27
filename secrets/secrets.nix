let
  pubkeys = import ../data/pubkeys.nix;
in
{
  "smb.age".publicKeys = pubkeys.ragon.computers;
  "nextshot.age".publicKeys = pubkeys.ragon.computers;
  "rootpasswd.age".publicKeys = pubkeys.ragon.computers;
  "ragonpasswd.age".publicKeys = pubkeys.ragon.computers;
}
