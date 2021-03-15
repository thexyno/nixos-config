let
  # If we have a locally defined secrets file, let's import it to
  # overwrite the dummy default secrets.
  realHashes = if builtins.pathExists ./secrets.nix then import ./secrets.nix else {};
in {
  # Dummy passwords to use for accounts, remember to create a secrets.nix
  # with newly generated passwords using the following command:
  # $ nix-shell --run 'mkpasswd -m SHA-512 -s' -p mkpasswd
  hashedRagonPassword = "$6$kgc3X2Axq$EJf5ivmtpNh2KlfQcLtaIdnsZ2cePLFUQ4E6pdedej028Z057WADHlQTIKoNdjQXIP1rmcinrWa/.Brh0z0lA.";
  hashedRootPassword = "$6$kgc3X2Axq$EJf5ivmtpNh2KlfQcLtaIdnsZ2cePLFUQ4E6pdedej028Z057WADHlQTIKoNdjQXIP1rmcinrWa/.Brh0z0lA.";
} // realHashes

