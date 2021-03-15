let
  # If we have a locally defined secrets file, let's import it to
  # overwrite the dummy default secrets.
  realHashes = if builtins.pathExists ./secrets.nix then import ./secrets.nix else {};
in {
  # Dummy passwords to use for accounts, remember to create a secrets.nix
  # with newly generated passwords using the following command:
  # $ nix-shell --run 'mkpasswd -m SHA-512 -s' -p mkpasswd
  hashedRagonPassword = "$6$V7SM4oyl$bwrAO0fhZL9.3M5Dk9BztGdYTRn4q6eadpBgtFMF2gmC0y2rSjpdtpTKJaHEbfrzWu/VP/D9GIP1v/20DUfYH0
7s";
  hashedRootPassword = "$6$V7SM4oyl$bwrAO0fhZL9.3M5Dk9BztGdYTRn4q6eadpBgtFMF2gmC0y2rSjpdtpTKJaHEbfrzWu/VP/D9GIP1v/20DUfYH0
7s";
} // realHashes

