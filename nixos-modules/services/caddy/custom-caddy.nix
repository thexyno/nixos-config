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
        "github.com/caddy-dns/desec@822a6a2014b221e8fa589fbcfd0395abe9ee90f6"
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

      outputHash = "sha256-Z2KQu4qayqaRudKfcxK4tLQ383//JZJ8q5vtX9/IX0I=";
      outputHashMode = "recursive";
    };

    subPackages = [ "." ];
    ldflags = [ "-s" "-w" ]; ## don't include version info twice
    vendorHash = null;
  });
}
