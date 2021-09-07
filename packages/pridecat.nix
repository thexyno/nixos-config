{ inputs, lib, fetchFromGitHub, stdenv, ...}:
stdenv.mkDerivation rec {
  version = "1.0.0";
  pname = "pridecat";
  src = inputs.pridecat;

  installPhase = ''
    install -D -m 755 ${pname} $out/bin/${pname}
  '';

  meta = with lib; {
    description = "Like cat, but more colorful - inspired by lolcat.";
    homepage = "https://github.com/lunasorcery/pridecat";
    license = licenses.cc-by-nc-40;
    platforms = platforms.linux ++ platforms.darwin;
  };

}
