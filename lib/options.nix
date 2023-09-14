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
      spl = lib.splitString "." domain;
      len = builtins.length spl;
      outerDomain = lib.traceVal (lib.concatStringsSep "." (lib.sublist (len - 2) len spl));
      domains = config.ragon.services.nginx.domains;
      hasDomain = lib.any (d: d == outerDomain) domains;
    in
    if hasDomain then {
      forceSSL = true;
      useACMEHost = "${outerDomain}";
    } else
      {
        forceSSL = true;
        enableACME = true;
      };

}
