{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.abcde;
  sources = import ../nix/sources.nix;
in
{
  options.ragon.abcde.enable = lib.mkEnableOption "Enables ragons abcde (CD Ripper) config";
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      abcde
    ];

    environment.etc."abcde.conf".text = ''
      CDDBMETHOD=musicbrainz
      # Encode tracks immediately after reading. Saves disk space, gives
      # better reading of 'scratchy' disks and better troubleshooting of
      # encoding process but slows the operation of abcde quite a bit:
      LOWDISK=y

      OUTPUTTYPE="flac"
      OUTPUTDIR="/media/data/Musik"               
      # Decide here how you want the tracks labelled for a standard 'single-artist',
      # multi-track encode and also for a multi-track, 'various-artist' encode:
      OUTPUTFORMAT=' ''${OUTPUT}/''${ARTISTFILE}/''${ALBUMFILE}/''${TRACKNUM}.''${TRACKFILE}'
      VAOUTPUTFORMAT=' ''${OUTPUT}/Various/''${ALBUMFILE}/''${TRACKNUM}.''${ARTISTFILE}-''${TRACKFILE}'
      # Decide here how you want the tracks labelled for a standard 'single-artist',
      # single-track encode and also for a single-track 'various-artist' encode.
      # (Create a single-track encode with 'abcde -1' from the commandline.)
      ONETRACKOUTPUTFORMAT=' ''${OUTPUT}/''${ARTISTFILE}/''${ALBUMFILE}/''${ALBUMFILE}'
      VAONETRACKOUTPUTFORMAT=' ''${OUTPUT}/Various/''${ALBUMFILE}/''${ALBUMFILE}'
      mungefilename ()
      {
        echo "$@" | sed -e 's/^\.*//' | tr -d ":><|*/\"'?[:cntrl:]"
      }
      
      ACTIONS=cddb,encode,move,embedalbumart,clean
      MAXPROCS=12                               # Run a few encoders simultaneously
      PADTRACKS=y                               # Makes tracks 01 02 not 1 2
      EXTRAVERBOSE=2                            # Useful for debugging
      COMMENT=""                                # Place a comment...
      EJECTCD=y                                 # Please eject cd when finished :-)
    '';

  };
}
