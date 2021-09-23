let
  ragon =
    let
      user = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMvexOT9tnx2LfAE/OwfixfNc/esNAjZ+GDfLpY2iABk" # enterprise ragon
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEJwOH1b6xWmEr1VZh48kBIYhW11vtPFR3my8stAHlSi" # saurier
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJwdsCeQUDRkAF/9Pfs5vySEit4kd5XGCgGR+CfZStAz" # voyager
      ];
      server = user ++ hosts.ds9 ++ hosts.wormhole ++ hosts.picard;
      client = user ++ hosts.enterprise ++ hosts.voyager;
      hosts = {
        wormhole = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO7Ab/50Bg9EncYbobC6kzdDzCDgvM1Tlf/9d+SDkO15" ];
        enterprise = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKXtH/ZY7u7ejf+EyzWleWRVUP8aNU5Gna5lpfVPRcuj" ];
        voyager = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKejPH5g1z8Syx5YhypidjMZ6itJTgDBBpfAVUIb4+a5" ];
        ds9 = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ+BBXufXAJhyUHVfhqlk8Y4zEKJbKXgJQvsdE482lpV" ];
        picard = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAm3UXZaN95WBUaS9SiHLNEuI1tP1x1w07qnYxPe+vdr" ];
        odyssey = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF1oyu6jDxST9Ane3KQ8MeM23MT5lLXQQt5g9J03gHBu" ];
      };
    in
    {
      inherit user server client hosts;
      computers = user ++ (builtins.foldl' (a: b: a ++ b) [ ] (builtins.attrValues hosts)); # everything
      host = hn: (hosts.${hn} ++ user);
    };
in
{
  inherit ragon;
}
