{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.services.ts3;
in
{
  options.ragon.services.ts3.enable = lib.mkEnableOption "Enables the Teamspeak 3 Server";
  config = lib.mkIf cfg.enable {
    services.teamspeak3 = {
      enable = true;
    };
    networking.firewall.allowedTCPPorts = [
      config.services.teamspeak3.queryPort
      config.services.teamspeak3.fileTransferPort
    ];
    networking.firewall.allowedUDPPorts = [
      config.services.teamspeak3.defaultVoicePort
    ];
    ragon.persist.extraDirectories = [
      "${config.services.teamspeak3.dataDir}"
    ];
  };
}
