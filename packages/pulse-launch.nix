{ lib, fetchFromGitHub, python3Packages }:
python3Packages.buildPythonApplication rec {
  version = "1.0.0";
  pname = "pulselaunch";
  src = fetchFromGitHub {
    owner = "ragon000";
    repo = "pulse-launch";
    rev = "bc5910eb3fcfa933a5ff84472948e70a92eff7b4";
    sha256 = "11n9mz8gs3zklm818a6g80g9panbz58q9qjh6zwmnrwvgnzf13wc";
  };
  meta = with lib; {
    description = "A simple python script to launch a command when a pulseaudio sink changes";
    homepage = "https://github.com/ragon000/pulse-launch";
    license = licenses.mit;
    platforms = platforms.linux;
  };

}
