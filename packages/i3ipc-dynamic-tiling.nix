{ inputs, lib, fetchFromGitHub, stdenv, python3, python3Packages, zip, ... }:
let
  py = python3.withPackages (pythonPackages: with pythonPackages; [ i3ipc ]);
in
stdenv.mkDerivation rec {
  version = "1.0.0";
  pname = "i3ipc-dynamic-tiling";
  src = inputs.i3ipc-dynamic-tiling;
  format = "other";
  doCheck = false;
  buildPhase = ''
    chmod +x i3ipc-dynamic-tiling
    chmod +x i3ipc_dynamic_tiling.py
  '';
  patchPhase = ''
    substituteInPlace i3ipc_dynamic_tiling.py \
      --replace "#!/usr/bin/env python3" "#!${py}/bin/python3" # hacky as shit
    substituteInPlace i3ipc-dynamic-tiling \
      --replace "python3" "${py}/bin/python3" # hacky as shit
    patchShebangs i3ipc-dynamic-tiling
  '';
  installPhase = ''
    install -D -m 755 i3ipc-dynamic-tiling $out/bin/i3ipc-dynamic-tiling
    install -D -m 755 i3ipc_dynamic_tiling.py $out/bin/i3ipc_dynamic_tiling.py
  '';
}
