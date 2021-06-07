let
  ragon =
    let
      pc = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMvexOT9tnx2LfAE/OwfixfNc/esNAjZ+GDfLpY2iABk"
      ];
      work = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEJwOH1b6xWmEr1VZh48kBIYhW11vtPFR3my8stAHlSi"
      ];
      host = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCScEol5a8Gh1P0t7w3FNjG6V9XEDcH2sJWgPJ41BpQ2Y70CKJ/ipcuzMoZLkidoeEuqaZXfQuv90acKbCJd7k0eEjpvOIpim0K/K7K+hajzkckEETaWLShjiHpYJMuDFJKLl+Lx3YjLbSIyUKDLtDeGfqj9G8/PjhiQnjNIkPXyqdVZJG7hEOcxzUKA6JkrOk+Okg7JSF8ZBCMDI//7EyctCP5gTJNdaN5GR2JL33Iyk/A+PngM6Lxjlu2oY+5vts2X6ntFEBFaktpPSCgqXTfGW5RefLEqFCReGAD3KYa5dmWkU431K7E3GqwiCyxcV9C5bDRYJne6Txf092D1dDKo+zCoTzi39y0TUMoVLwNARLYM4CW4uIZcMGYDqYEzPxU0NkrbU8i32zZ2FGoHBMbPhgecm+v6qxZbCKWNM/vaY+qK9fW5uDyktnOyeaFj0XeSV3udO/kLt2yYuRejv9Uc72WAzuNG7ouFEh8uyDalLZgouY5YBJHvaRjVg/oBTs=" # root
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKXtH/ZY7u7ejf+EyzWleWRVUP8aNU5Gna5lpfVPRcuj" # enterprise hostkey
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKejPH5g1z8Syx5YhypidjMZ6itJTgDBBpfAVUIb4+a5" # voyager hostkey
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO7Ab/50Bg9EncYbobC6kzdDzCDgvM1Tlf/9d+SDkO15" # wormhole hostkey

      ];
    in
    {
      inherit pc work;
      computers = pc ++ work ++ host;

    };
in
{
  inherit ragon;
}
