{ inputs, config, lib, pkgs, ... }:
let
  cfg = config.ragon.home-manager;
  isGui = config.ragon.gui.enable;
in
{
  config = lib.mkIf cfg.enable {
    home-manager.users.${config.ragon.user.username} = { pkgs, lib, ... }:
      {
        programs = {
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

