{ inputs, config, lib, pkgs, ... }:
let
  cfg = config.ragon.home-manager;
  isGui = config.ragon.gui.enable;
in
{
  config = lib.mkIf cfg.enable {
    ragon.user.persistent.extraDirectories = [
      ".gnupg"
    ];
    home-manager.users.${config.ragon.user.username} = { pkgs, lib, ... }:
      {
        programs = {
          gpg = {
            enable = true;
            settings = {
              personal-cipher-preferences = "AES256 AES192 AES";
              personal-digest-preferences = "SHA512 SHA384 SHA256";
              personal-compress-preferences = "ZLIB BZIP2 ZIP Uncompressed";
              default-preference-list = "SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed";
              cert-digest-algo = "SHA512";
              s2k-digest-algo = "SHA512";
              s2k-cipher-algo = "AES256";
              charset = "utf-8";
              fixed-list-mode = true;
              no-comments = true;
              no-emit-version = true;
              no-greeting = true;
              list-options = "show-uid-validity";
              verify-options = "show-uid-validity";
              with-fingerprint = true;
              with-key-origin = true;
              require-cross-certification = true;
              no-symkey-cache = true;
              use-agent = true;
              throw-keyids = true;
              keyserver = "hkps://keyserver.ubuntu.com:443";
              verbose = true;
              list-options = "show-unusable-subkeys";
            };
          };
          bat = {
            enable = true;
            config.theme = "gruvbox-dark";
          };
          fzf = {
            enable = true;
            enableZshIntegration = true;
            defaultOptions = [
              "--height 40%"
              "--layout=reverse"
              "--border"
              "--inline-info"
            ];
          };
          git = {
            enable = true;
            lfs.enable = true;

            # Default configs
            extraConfig = {
              commit.gpgSign = true;

              user.name = "Philipp Hochkamp";
              user.email = "me@phochkamp.de";
              user.signingKey = "26F03E1F60F5731B0CC5BDE1C4F2B751AA7341B3";

              # Set default "git pull" behaviour so it doesn't try to default to
              # either "git fetch; git merge" (default) or "git fetch; git rebase".
              pull.ff = "only";
            };
          };
          # Htop configurations
          htop = {
            enable = true;
            settings = {
              hide_userland_threads = true;
              highlight_base_name = true;
              shadow_other_users = true;
              show_program_path = false;
              tree_view = false;
              left_meters = [ "LeftCPUs" "Memory" "Swap" "ZFSARC" ];
              right_meters = [ "RightCPUs" "Tasks" "LoadAverage" "Uptime" "Battery" ];
            };
          };


          rofi = {
            enable = true;
            font = "JetBrains Mono Medium 10";
            terminal = "${pkgs.kitty}/bin/kitty";
            extraConfig = {
              modi = "drun,run,ssh,combi";
              theme = "gruvbox-dark-soft";
              combi-modi = "drun,run,ssh";
            };
          };
        };
      };
  };
}

