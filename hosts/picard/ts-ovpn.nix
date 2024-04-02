{ config, pkgs, options, ... }: {
  imports = [
    ../../nixos-modules/services/tailscale-openvpn.nix
    ../../nixos-modules/system/agenix.nix
  ];
  ragon = {
    agenix.secrets."ovpnNl" = { };
    agenix.secrets."ovpnDe" = { };
    agenix.secrets."ovpnTu" = { };
    agenix.secrets."ovpnCrt1" = { };
    agenix.secrets."ovpnPw1" = { };
    agenix.secrets."ovpnPw2" = { };
    agenix.secrets."ovpnScript" = { };
    agenix.secrets."tailscaleKey" = { };
    services.tailscale-openvpn = {
      enable = true;
      tsAuthKey = config.age.secrets.tailscaleKey.path;
      config = {
        nl = config.age.secrets.ovpnNl.path;
        de = config.age.secrets.ovpnDe.path;
        tu = config.age.secrets.ovpnTu.path;
      };
      script = config.age.secrets.ovpnScript.path;
    };
  };
}
