{ inputs, lib, fetchFromGitHub, stdenv, libX11, libGL, ...}:
stdenv.mkDerivation rec {
  version = "1.0.0";
  pname = "cnping";
  src = inputs.cnping;
  nativeBuildInputs = [ libX11 libGL ];

  installPhase = ''
    install -D -m 755 ${pname} $out/bin/${pname}
  '';

  meta = with lib; {
    description = "minimal graphical ping";
    homepage = "https://github.com/cnlohr/cnping";
    license = licenses.mit;
    platforms = platforms.linux ++ platforms.darwin;
  };

}
