{ lib, fetchFromGitHub, stdenv }:
stdenv.mkDerivation rec {
  version = "1.0.0";
  name = "pridecat-${version}";
  src = fetchFromGitHub {
    owner = "lunasorcery";
    repo = "pridecat";
    rev = "92396b11459e7a4b5e8ff511e99d18d7a1589c96";
    sha256 = "PyGLbbsh9lFXhzB1Xn8VQ9zilivycGFEIc7i8KXOxj8=";
    fetchSubmodules = true;
  };

  meta = with lib; {
    description = "Like cat, but more colorful - inspired by lolcat.";
    homepage = "https://github.com/lunasorcery/pridecat";
    license = licenses.cc-by-nc-40;
    platforms = platforms.linux ++ platforms.darwin;
  };

}
