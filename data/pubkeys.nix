let
  ragon =
    let
      user = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEJwOH1b6xWmEr1VZh48kBIYhW11vtPFR3my8stAHlSi" # saurier
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIuwQJY0H/fdu1UmGXAut7VfcvAk2Dm78tJpkyyv2in2" # daedalus
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKZ0hlF6EFQXpw74kkpoA8vxMX6vVDTnpM41rCDXRMuo" # daedalusvm
      ];
      server = user ++ hosts.ds9 ++ hosts.picard;
      client = user;
      hosts = {
        ds9 = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ+BBXufXAJhyUHVfhqlk8Y4zEKJbKXgJQvsdE482lpV" ];
        picard = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAm3UXZaN95WBUaS9SiHLNEuI1tP1x1w07qnYxPe+vdr" ];
        daedalusvm = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKJCNGGsnAPPmhQnEMBWJulM2pi3pw/tdX1vi3l6cRky" ];
        octopi = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN+0/lwNc/KN8LrS3KvDCuuipQokO+7qELfksepJXz6a" ];
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
