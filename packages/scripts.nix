{ stdenv, ...}:
stdenv.mkDerivation {
  name = "scripts";
  src = ../scripts;
  installPhase = ''
    mkdir -p $out/bin
    cp * $out/bin
  '';
}
