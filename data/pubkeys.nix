let
  ragon =
    let
      user = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMvexOT9tnx2LfAE/OwfixfNc/esNAjZ+GDfLpY2iABk" # enterprise ragon
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEJwOH1b6xWmEr1VZh48kBIYhW11vtPFR3my8stAHlSi" # saurier
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJwdsCeQUDRkAF/9Pfs5vySEit4kd5XGCgGR+CfZStAz" # voyager
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIuwQJY0H/fdu1UmGXAut7VfcvAk2Dm78tJpkyyv2in2" # daedalus
      ];
      server = user ++ hosts.ds9 ++ hosts.wormhole ++ hosts.picard ++ hosts.octopi;
      client = user ++ hosts.enterprise ++ hosts.voyager;
      hosts = {
        wormhole = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINzR5dq/2UosH3nLrc9PvJi3rzX917K2wICeOUAiDnl6" ];
        daedalusvm = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL9gTeFNEO+Puf8j0rxq0qyR+OgH0eSqDYBR20aACkpP" ];
        enterprise = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKXtH/ZY7u7ejf+EyzWleWRVUP8aNU5Gna5lpfVPRcuj" ];
        voyager = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKejPH5g1z8Syx5YhypidjMZ6itJTgDBBpfAVUIb4+a5" ];
        ds9 = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ+BBXufXAJhyUHVfhqlk8Y4zEKJbKXgJQvsdE482lpV" ];
        picard = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAm3UXZaN95WBUaS9SiHLNEuI1tP1x1w07qnYxPe+vdr" ];
        odyssey = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICGJ/AeaPwEblvpbxx5RGc9205H3eytJusLDJKN63LiJ" ];
        octopi = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPRhKTcmYaM0yNYScEUBP8WV56MBvmLzXhJXcbDTGeea ragon@enterprise" ];
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
