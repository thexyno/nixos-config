{ options, config, lib, pkgs, ... }:
with lib;
{
  options.ragon.services.tailscale-openvpn = {
    enable = mkEnableOption "Tailscale OpenVPN Bridge";
    config = mkOption {
      type = types.attrsOf types.str;
    };
    tsAuthKey = mkOption { type = types.str; };
  };
  config =
    let
      cfg = config.ragon.services.tailscale-openvpn;
      bridgeExt = "br-ovpn-ext";
      container = server: "ovpn-${server}";
      bridge = server: "br-ovpn-${server}";
    in
    mkIf cfg.enable
      {
        networking.bridges = {
          ${bridgeExt}.interfaces = [ ];
        };
        networking.interfaces = {
          ${bridgeExt}.ipv4.addresses = [{ address = "192.168.129.1"; prefixLength = 24; }];
        };

        networking.nat = {
          enable = true;
          internalInterfaces = [ bridgeExt ];
        };


        systemd.services = {
          "container@".after = [ "network.target" ];
        } // (mapAttrs'
          (server: _: nameValuePair ("container@${container server}") ({ requires = [ "network-addresses-${bridgeExt}.service" ]; }))
          cfg.config
        );
        containers = builtins.listToAttrs (imap0
          (i: name: nameValuePair name
            {
              autoStart = true;
              ephemeral = true;
              enableTun = true;
              privateNetwork = true;
              hostBridge = bridgeExt;
              localAddress = "192.168.129.${toString (i + 2)}/24";
              bindMounts = {
                "/host/run" = { hostPath = "/run"; isReadOnly = true; };
                "/run/agenix.d" = { hostPath = "/run/agenix.d"; isReadOnly = true; };
              };
              config = {
                services.openvpn.servers.${name} = {
                  config = ''
                    config ${cfg.config.${name}}
                  '';
                  up = "echo nameserver $nameserver | ${pkgs.openresolv}/sbin/resolvconf -m 0 -a $dev";
                  down = "${pkgs.openresolv}/sbin/resolvconf -d $dev";
                };
                services.tailscale = {
                  enable = true;
                  useRoutingFeatures = "server";
                  extraUpFlags = [ "--advertise-exit-node" ];
                  authKeyFile = cfg.tsAuthKey;
                  openFirewall = true;
                };
              };

            })
          (builtins.attrNames cfg.config));



      };
}
