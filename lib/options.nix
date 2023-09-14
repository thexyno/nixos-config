{ lib, ... }:

let
  inherit (lib) mkOption types;
in
rec {
  mkOpt = type: default:
    mkOption { inherit type default; };

  mkOpt' = type: default: description:
    mkOption { inherit type default description; };

  mkBoolOpt = default: mkOption {
    inherit default;
    type = types.bool;
    example = true;
  };
  findOutTlsConfig = domain: config:
    let
      spl = builtins.splitString "." domain;
      outerDomain = builtins.concatStringsSep "." (builtins.take (builtins.length spl - 1) spl);
    in
    lib.mkMerge [
      ((lib.hasAttr outerDomain config.acme.certs) && {
        forceSSL = true;
        useACMEHost = "${domain}";
      })
      (!(lib.hasAttr outerDomain config.acme.certs) && {
        forceSSL = true;
        enableACME = true;
      })
    ];

}
