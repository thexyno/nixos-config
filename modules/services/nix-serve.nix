{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.services.nix-serve;
  domain = config.ragon.services.nginx.domain;
in
{
  options.ragon.services.nix-serve.enable = lib.mkEnableOption "Enables nix-serve";
  options.ragon.services.nix-serve.domainPrefix =
    lib.mkOption {
      type = lib.types.str;
      default = "nix";
    };
  config = lib.mkIf cfg.enable {
    services.nix-serve = {
      enable = true;
      secretKeyFile = "/var/lib/nix-cache/cache-priv-key.pem";
    };
    services.nginx.virtualHosts."${cfg.domainPrefix}.${domain}" = {
      forceSSL = true;
      useACMEHost = "${domain}";
      locations."/".extraConfig = ''
        proxy_pass http://localhost:${toString config.services.nix-serve.port};
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      '';
    };
    ragon.persist.extraDirectories = [
      "/var/lib/nix-cache"
    ];
  };
}
