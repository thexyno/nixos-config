let
  ragon = let
    pc = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMvexOT9tnx2LfAE/OwfixfNc/esNAjZ+GDfLpY2iABk"
    ];
    work = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEJwOH1b6xWmEr1VZh48kBIYhW11vtPFR3my8stAHlSi"
    ];
  in
   {
    inherit pc work;
    computers = pc ++ work;
  };
in {
  inherit ragon;
}
