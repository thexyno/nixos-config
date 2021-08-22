{ stdenv, lib, inputs, fetchFromGitHub, nodePackages, glib ,... }:
stdenv.mkDerivation rec {
  pname = "gnome-shell-extension-pop-shell";
  version = "2";

  src = inputs.pop-shell;

  makeFlags = [ "DESTDIR=$(out)" ];
  buildInputs = [ glib nodePackages.typescript ];

  postInstall = ''
    mv $out/usr/* $out
    rmdir $out/usr
  '';

  meta = with lib; {
    description = "i3wm-like keyboard-driven layer for GNOME Shell";
    homepage = "https://github.com/pop-os/shell";
    license = licenses.gpl3;
    maintainers = with maintainers; [ elyhaka ];
    platforms = platforms.linux;
  };
}
