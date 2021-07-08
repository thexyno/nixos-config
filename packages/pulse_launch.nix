{ lib, stdenv, fetchFromGitHub, python3Packages }:
with lib;
stdenv.mkDerivation rec {
  version = "1.0.0";
  pname = "pulse_launch";
  propagatedBuildInputs = with python3Packages; [ pulsectl ];
  src = fetchFromGitHub {
    owner = "ragon000";
    repo = "pulse-launch";
    rev = "bc5910eb3fcfa933a5ff84472948e70a92eff7b4";
    sha256 = "11n9mz8gs3zklm818a6g80g9panbz58q9qjh6zwmnrwvgnzf13wc";
  };
  installPhase = ''
    install -D -m 755 ${pname}.py $out/bin/${pname}
  '';
  meta = with lib; {
    description = "A simple python script to launch a command when a pulseaudio sink changes";
    homepage = "https://github.com/ragon000/pulse-launch";
    license = licenses.mit;
    platforms = platforms.linux;
  };

}
