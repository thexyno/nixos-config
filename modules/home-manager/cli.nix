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
              cert-digest-algo = "SHA512";
              charset = "utf-8";
              default-preference-list = "SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed";
              fixed-list-mode = true;
              keyserver = "hkps://keyserver.ubuntu.com:443";
              list-options = [ "show-uid-validity" "show-unusable-subkeys" ];
              no-comments = true;
              no-emit-version = true;
              no-greeting = true;
              no-symkey-cache = true;
              personal-cipher-preferences = "AES256 AES192 AES";
              personal-compress-preferences = "ZLIB BZIP2 ZIP Uncompressed";
              personal-digest-preferences = "SHA512 SHA384 SHA256";
              require-cross-certification = true;
              s2k-cipher-algo = "AES256";
              s2k-digest-algo = "SHA512";
              throw-keyids = true;
              use-agent = true;
              verbose = true;
              verify-options = "show-uid-validity";
              with-fingerprint = true;
              with-key-origin = true;
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
              user.email = "git@phochkamp.de";
              user.signingKey = "DA5D9235BD5BD4BD6F4C2EA868066BFF4EA525F1";

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
            };
          };


        };
      };
  };
}

