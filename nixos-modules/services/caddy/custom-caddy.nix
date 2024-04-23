{ pkgs, ... }:

with pkgs;

caddy.override {
  buildGoModule = args: buildGoModule (args // {
    src = stdenv.mkDerivation rec {
      pname = "caddy-using-xcaddy-${xcaddy.version}";
      inherit (caddy) version;

      dontUnpack = true;
      dontFixup = true;

      nativeBuildInputs = [
        cacert
        go
      ];

      plugins = [
        "github.com/caddy-dns/ionos@751e8e24162290ee74bea465ae733a2bf49551a6"
        "github.com/caddy-dns/desec@e1e64971fe34c29ce3f4176464adb84d6890aa50"
      ];

      configurePhase = ''
        export GOCACHE=$TMPDIR/go-cache
        export GOPATH="$TMPDIR/go"
        export XCADDY_SKIP_BUILD=1
      '';

      buildPhase = ''
        ${xcaddy}/bin/xcaddy build "${caddy.src.rev}" ${lib.concatMapStringsSep " " (plugin: "--with ${plugin}") plugins}
        cd buildenv*
        go mod vendor
      '';

      installPhase = ''
        cp -r --reflink=auto . $out
      '';

      outputHash = "sha256-6VWB9EYWkJ5WlQfRtJxpSekVpT1i+/6wFFXJUPGeB88=";
      outputHashMode = "recursive";
    };

    subPackages = [ "." ];
    ldflags = [ "-s" "-w" ]; ## don't include version info twice
    vendorHash = null;
  });
}
