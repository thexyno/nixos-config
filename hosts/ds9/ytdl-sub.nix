{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib;
let
  channels = {
    "Entertainment" = [
      "2BoredGuysOfficial"
      "AlexPrinz"
      "BagelBoyOfficial"
      "DiedeutschenBackrooms"
      "DankPods"
      "Defunctland"
      "Ididathing"
      "GarbageTime420"
      "Boy_Boy"
      "ContraPoints"
      "PhilosophyTube"
      "PosyMusic"
      "RobBubble"
      "agingwheels"
      "NileBlue"
      "NileRed"
      "styropyro"
      "williamosman"
      "billwurtz"
      "f4micom"
      "hbomberguy"
      "simonegiertz"
      "Parabelritter"
      "DeviantOllam"
      "MaxFosh"
      "MichaelReeves"
      "TomScottGo"
      "WilliamOsman2"
    ];
    "Tism" = [
      "Echoray1" # alwin meschede
      "TechnologyConnections"
      "TechnologyConnextras"
      "TheB1M"
      "bahnblick_eu"
      "jameshoffmann"
      "scottmanley"
      "theCodyReeder"
      "standupmaths"
    ];
    "Making" = [
      "DIYPerks"
      "MaxMakerChannel"
      "Nerdforge"
      "iliketomakestuff"
      "ZackFreedman"

    ];
    "Games" = [
      "TylerMcVicker1"
      "gabe.follower"
      "altf4games"
    ];
    "Programming" = [
      "BenEater"
      "NoBoilerplate"
      "stacksmashing"
    ];
    "Tech" = [
      "LinusTechTips"
    ];
  };
in

{
  systemd.services."ytdl-sub-default".serviceConfig.ReadWritePaths = [ "/data/media/yt" ];
  services.ytdl-sub = {
    instances.default = {
      enable = true;
      schedule = "0/6:0";
      config = {
        presets."Sponsorblock" = {
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
            embed_chapters = true;
            sponsorblock_categories = [
              # "outro"
              "selfpromo"
              "preview"
              "interaction"
              "sponsor"
              "music_offtopic"
              # "intro"
            ];
            remove_sponsorblock_categories = "all";
            force_key_frames = false;
          };
        };
      };
      subscriptions = {
        "__preset__".overrides = {
          tv_show_directory = "/data/media/yt";
          only_recent_max_files = 30;
          # only_recent_date_range = "30days";
        };
        "Jellyfin TV Show by Date | Sponsorblock | Only Recent | Max 1080p" = mapAttrs' (
          n: v:
          nameValuePair "= ${n}" (
            builtins.listToAttrs (builtins.map (x: (nameValuePair x "https://youtube.com/@${x}")) v)
          )
        ) channels;
        "Jellyfin TV Show Collection | Sponsorblock" = {
          "~Murder Drones" = {
            s01_url = "https://www.youtube.com/playlist?list=PLHovnlOusNLiJz3sm0d5i2Evwa2LDLdrg";
            tv_show_collection_episode_ordering = "playlist-index";
          };
        };
      };
    };
    group = "users";

  };
}
