{ lib, fetchFromGitHub, stdenv, libX11, libGL, ...}:
stdenv.mkDerivation rec {
  version = "1.0.0";
  pname = "cnping";
  src = fetchFromGitHub {
    owner = "cnlohr";
    repo = "cnping";
    rev = "6b89363e6b79ecbf612306d42a8ef94a5a2f756a";
    sha256 = "101gcswscaz46478ama3xdvk4g5l3fhwja5nmg3qc2zsibkacx8k";
    fetchSubmodules = true;
  };
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
