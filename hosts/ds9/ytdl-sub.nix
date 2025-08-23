{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  channels = [
    "2BoredGuysOfficial"
    "AlexPrinz"
    "BagelBoyOfficial"
    "BenEater"
    "Boy_Boy"
    "ContraPoints"
    "DIYPerks"
    "DankPods"
    "Defunctland"
    "DeviantOllam"
    "GarbageTime420"
    "Ididathing"
    "LinusTechTips"
    "MaxFosh"
    "MaxMakerChannel"
    "MichaelReeves"
    "Nerdforge"
    "NileBlue"
    "NileRed"
    "NoBoilerplate"
    "Parabelritter"
    "PhilosophyTube"
    "PosyMusic"
    "RobBubble"
    "TechnologyConnections"
    "TechnologyConnextras"
    "TheB1M"
    "TomScottGo"
    "TylerMcVicker1"
    "WilliamOsman2"
    "ZackFreedman"
    "agingwheels"
    "altf4games"
    "billwurtz"
    "f4micom"
    "gabe.follower"
    "hbomberguy"
    "iliketomakestuff"
    "jameshoffmann"
    "simonegiertz"
    "stacksmashing"
    "standupmaths"
    "styropyro"
    "theCodyReeder"
    "williamosman"
  ];
in

{
  systemd.services."ytdl-sub-default".serviceConfig.ReadWritePaths = ["/data/media/yt"];
  services.ytdl-sub = {
    instances.default = {
      enable = true;
      schedule = "0/6:0";
      config = {
        presets."TV Show" = {
          ytdl_options.cookiefile = "/data/media/yt/cookies.Personal.txt";
          subtitles = {
            embed_subtitles = true;
            languages = [
              "en"
              "de"
            ];
            allow_auto_generated_subtitles = false;
          };
          chapters = {
            sponsorblock_categories = [
              "sponsor"
              "selfpromo"
            ];

            remove_sponsorblock_categories = "all";
          };
        };
      };
      subscriptions = {
        "__preset__".overrides.tv_show_directory = "/data/media/yt";
        "Jellyfin TV Show by Date | Only Recent | Max 1080p" = builtins.listToAttrs (
          builtins.map (x: {
            name = x;
            value = "https://youtube.com/@${x}";
          }) channels
        );
        "Jellyfin TV Show Collection" = {
          "Murder Drones" = "https://www.youtube.com/playlist?list=PLHovnlOusNLiJz3sm0d5i2Evwa2LDLdrg";
        };
      };
    };
    group = "users";

  };
}
