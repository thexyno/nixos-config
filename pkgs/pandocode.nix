{ pkgs, lib, stdenv, fetchurl, python, python38Packages, zip }:
let
  sources = import ../nix/sources.nix;
in
stdenv.mkDerivation rec {
  version = "1.0.1";
  name = "pandocode-${version}";
  buildInputs = [ python zip python38Packages.panflute python38Packages.pylint ];
  src = sources.pandocode;
  buildPhase = ''
    make PREFIX=$(out) \
      PY=${pkgs.python3}/bin/python \
      PYLINT=true \
      pandocode.pyz.zip

    echo "${pkgs.python3}/bin/python" | cat - pandocode.pyz.zip > pandocode
  '';
  installPhase = ''
    install -D -m 755 pandocode $(out)/bin/pandocode
  '';
  meta = with lib; {
    description = "pandocode is a pandoc filter that converts Python (-like) code to LaTeX-Pseudocode";
    homepage = "https://github.com/nzbr/pandocode";
    license = licenses.isc;
    platforms = stdenv.lib.platforms.linux ++ stdenv.lib.platforms.darwin;
  };

}
