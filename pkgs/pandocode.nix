{ pkgs, lib, stdenv, fetchurl, python3, python3Packages, zip }:
let
  sources = import ../nix/sources.nix;
in
stdenv.mkDerivation rec {
  version = "1.0.1";
  name = "pandocode-${version}";
  buildInputs = [ python3 zip python3Packages.panflute python3Packages.pylint ];
  propagatedBuildInputs = [python3Packages.panflute];
  src = sources.pandocode;
  buildPhase = ''
    make PREFIX=$out \
      PY=${python3}/bin/python3 \
      PYLINT=true \
      pandocode.pyz.zip

    echo "#!${python3}/bin/python3" | cat - pandocode.pyz.zip > pandocode
  '';
  installPhase = ''
    install -D -m 755 pandocode $out/bin/pandocode
  '';
  meta = with lib; {
    description = "pandocode is a pandoc filter that converts Python (-like) code to LaTeX-Pseudocode";
    homepage = "https://github.com/nzbr/pandocode";
    license = licenses.isc;
    platforms = stdenv.lib.platforms.linux ++ stdenv.lib.platforms.darwin;
  };

}
