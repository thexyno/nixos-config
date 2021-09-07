{ inputs, lib, stdenv, fetchFromGitHub, python3Packages, python3, ... }:
let
  py = python3.withPackages (pythonPackages: with pythonPackages; [ pulsectl ]);
in
stdenv.mkDerivation rec {
  version = "1.0.0";
  pname = "pulse_launch";
  format = "other";
  doCheck = false;
  src = inputs.pulse-launch;
  buildPhase = ''
    echo "#!${py}/bin/python3" | cat - ${pname}.py > ${pname}
  '';
  installPhase = ''
    install -D -m 755 ${pname} $out/bin/${pname}
  '';
  meta = with lib; {
    description = "A simple python script to launch a command when a pulseaudio sink changes";
    homepage = "https://github.com/ragon000/pulse-launch";
    license = licenses.mit;
    platforms = platforms.linux;
  };

}
