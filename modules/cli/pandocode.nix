{ stdenv, fetchurl, python, zip }:
let
  sources = import ../../nix/sources.nix;
in
stdenv.mkDerivation rec {
  version = "1.0.1";
  name = "pandocode-${version}";
  buildInputs = [ python zip ];
  makeFlags = [ "PREFIX=$(out)" ];
  src = sources.pandocode;
  meta = with stdenv.lib; {
    description = "pandocode is a pandoc filter that converts Python (-like) code to LaTeX-Pseudocode";
    homepage = "https://github.com/nzbr/pandocode";
    license = licenses.isc;
    platforms = stdenv.lib.platforms.linux ++ stdenv.lib.platforms.darwin;
  };

}
