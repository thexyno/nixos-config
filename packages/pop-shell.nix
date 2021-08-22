{ stdenv, lib, inputs, fetchFromGitHub, nodePackages, glib ,... }:
stdenv.mkDerivation rec {
  pname = "gnome-shell-extension-pop-shell";
  version = "2";

  src = inputs.pop-shell;

  nativeBuildInputs = [
    nodePackages.typescript
    glib
  ];

  makeFlags = [ "INSTALLBASE=$(out)/share/gnome-shell/extensions" ];

  postInstall = ''
    mkdir -p $out/share/gsettings-schemas/pop-shell-${version}/glib-2.0
    cp -R $out/share/gnome-shell/extensions/${uuid}/schemas \
          $out/share/gsettings-schemas/pop-shell-${version}/glib-2.0/schemas
  '';

  uuid = "pop-shell@system76.com";

  meta = with lib; {
    description = "i3wm-like keyboard-driven layer for GNOME Shell";
    homepage = "https://github.com/pop-os/shell";
    license = licenses.gpl3;
    maintainers = with maintainers; [ elyhaka ];
    platforms = platforms.linux;
  };
}
