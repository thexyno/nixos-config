{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.services.tailscale;
in
{
  options.ragon.services.tailscale.enable = lib.mkEnableOption "Enables tailscale";
  options.ragon.services.tailscale.exitNode = lib.mkEnableOption "Exit Node";
  options.ragon.services.tailscale.extraUpCommands = lib.my.mkOpt lib.types.str "";
  config = lib.mkIf cfg.enable {
    # enable the tailscale service
    ragon.persist.extraDirectories = [
      "/var/lib/tailscale"
    ];
    services.tailscale.enable = true;
    ragon.agenix.secrets.tailscaleKey = { };
    boot.kernel.sysctl = lib.mkIf cfg.exitNode {
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    };
    networking.firewall = {
      # always allow traffic from your Tailscale network
      trustedInterfaces = [ "tailscale0" ];


      checkReversePath = lib.mkDefault "loose";
      # allow the Tailscale UDP port through the firewall
      allowedUDPPorts = [ config.services.tailscale.port ];
    };
    systemd.services.tailscale-autoconnect = {
      description = "Automatic connection to Tailscale";

      # make sure tailscale is running before trying to connect to tailscale
      after = [ "network-pre.target" "tailscale.service" ];
      wants = [ "network-pre.target" "tailscale.service" ];
      wantedBy = [ "multi-user.target" ];

      # set this service as a oneshot job
      serviceConfig.Type = "oneshot";

      # have the job run this shell script
      script = with pkgs; ''
        # wait for tailscaled to settle
        sleep 2

        # check if we are already authenticated to tailscale
        status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
        if [ $status = "Running" ]; then # if so, then do nothing
          exit 0
        fi
        key=$(<${config.age.secrets.tailscaleKey.path})
        # otherwise authenticate with tailscale
        ${tailscale}/bin/tailscale up -authkey $key ${lib.optionalString cfg.exitNode "--advertise-exit-node"} ${cfg.extraUpCommands}
      '';
    };
  };
}
