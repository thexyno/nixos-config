let
  ragon =
    let
      user = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEJwOH1b6xWmEr1VZh48kBIYhW11vtPFR3my8stAHlSi" # saurier
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIuwQJY0H/fdu1UmGXAut7VfcvAk2Dm78tJpkyyv2in2" # daedalus
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKZ0hlF6EFQXpw74kkpoA8vxMX6vVDTnpM41rCDXRMuo" # daedalusvm
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC6xx1IWlRoSQvCUZ+iyzekjFjoXBKmDT4Kxww4Tl+63" # iPad
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJmN2QRbwQyeUChQ0ZxNzjNnUZTOUVbM4kDEGfEtmufc" # iPhone
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID/oMAi5jyQsNohfhcSH2ItisTpBGB0WtYTVxJYKKqhj" # theseus
      ];
      server = user ++ hosts.ds9 ++ hosts.picard;
      client = user;
      hosts = {
        ds9 = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ+BBXufXAJhyUHVfhqlk8Y4zEKJbKXgJQvsdE482lpV" ];
        picard = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAm3UXZaN95WBUaS9SiHLNEuI1tP1x1w07qnYxPe+vdr" ];
        theseus = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP/pPCcq0ziQhdyZSObly3bUUJqH56Ly+uYS6MNdR2D+"];
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
