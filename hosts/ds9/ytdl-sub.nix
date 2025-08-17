{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  channels = [
    "WilliamOsman2"
    "TechnologyConnections"
    "GarbageTime420"
    "LinusTechTips"
    "gabe.follower"
    "TheB1M"
    "2BoredGuysOfficial"
    "DankPods"
    "Ididathing"
    "Boy_Boy"
    "TylerMcVicker1"
    "PosyMusic"
    "jameshoffmann"
    "NoBoilerplate"
    "Parabelritter"
    "TomScottGo"
    "f4micom"
    "DeviantOllam"
    "styropyro"
    "Defunctland"
    "BenEater"
    "stacksmashing"
    "ZackFreedman"
    "MaxMakerChannel"
    "agingwheels"
    "PhilosophyTube"
    "Nerdforge"
    "AlexPrinz"
    "MaxFosh"
    "BagelBoyOfficial"
    "hbomberguy"
    "ContraPoints"
    "RobBubble"
    "standupmaths"
    "theCodyReeder"
    "NileRed"
    "NileBlue"
    "TechnologyConnextras"
    "simonegiertz"
    "billwurtz"
    "MichaelReeves"
    "williamosman"
    "iliketomakestuff"
    "altf4games"
    "DIYPerks"
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
