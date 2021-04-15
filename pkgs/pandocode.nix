{ lib, stdenv, python3, python3Packages, zip }:
let
  sources = import ../nix/sources.nix;
  py = pkgs.python3.withPackages (pythonPackages: with pythonPackages; [ panflute ]);
in
stdenv.mkDerivation rec {
  version = "1.0.1";
  name = "pandocode-${version}";
  nativeBuildInputs = [ zip ];
  src = sources.pandocode;
  format = "other";
  doCheck = false;
  buildPhase = ''
    make PREFIX=$out \
      PY=${py}/bin/python3 \
      PYLINT=true \
      pandocode.pyz.zip

    echo "#!/usr/bin/python3" | cat - pandocode.pyz.zip > pandocode
  '';
  installPhase = ''
    install -D -m 755 pandocode $out/bin/pandocode
  '';
  meta = with lib; {
    description = "pandocode is a pandoc filter that converts Python (-like) code to LaTeX-Pseudocode";
    homepage = "https://github.com/nzbr/pandocode";
    license = licenses.isc;
    platforms = platforms.linux ++ platforms.darwin;
  };

}
