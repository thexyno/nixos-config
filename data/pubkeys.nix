let
  ragon =
    let
      user = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEJwOH1b6xWmEr1VZh48kBIYhW11vtPFR3my8stAHlSi" # saurier
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIuwQJY0H/fdu1UmGXAut7VfcvAk2Dm78tJpkyyv2in2" # daedalus
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBWd5d20Q3bmme9eVHbCphIJ7TvP/llTxXvRT1xYl6xm" # daedalusvm
      ];
      server = user ++ hosts.ds9 ++ hosts.picard;
      client = user;
      hosts = {
        ds9 = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ+BBXufXAJhyUHVfhqlk8Y4zEKJbKXgJQvsdE482lpV" ];
        picard = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAm3UXZaN95WBUaS9SiHLNEuI1tP1x1w07qnYxPe+vdr" ];
        daedalusvm = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMmScjeua/5JC1vKeV0jDMC9ravORscENZVvshEJ1X0u" ];
      };
    in
    {
      inherit user server client;
      computers = user ++ (builtins.foldl' (a: b: a ++ b) [ ] (builtins.attrValues hosts)); # everything
      host = hn: (hosts.${hn} ++ user);
      hosts = hn: ((map (x: hosts.${x}) hn) ++ user);
    };
in
{
  inherit ragon;
}
