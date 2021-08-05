{ inputs, config, lib, pkgs, ... }:
let
  cfg = config.ragon.home-manager;
  isGui = config.ragon.gui.enable;
in
{
  config = lib.mkIf cfg.enable {
    home-manager.users.${config.ragon.user.username} = { pkgs, lib, ... }:
      {
        xdg.dataFile = {
          "applications/Firefox (Work).desktop".text = ''
            [Desktop Entry]
            Categories=Network;WebBrowser;
            Comment=
            Exec=firefox -P Work %U
            GenericName=Web Browser (Work)
            Icon=firefox
            Name=Firefox (Work)
            Terminal=false
            Type=Application
          '';

        };
        xdg.mimeApps = {
          enable = isGui;
          defaultApplications = {
            "text/html" = [ "firefox.desktop" ];
            "application/pdf" = [ "org.pwmt.zathura.desktop" ]; #
            "x-scheme-handler/http" = [ "firefox.desktop" ];
            "x-scheme-handler/https" = [ "firefox.desktop" ];
            "x-scheme-handler/about" = [ "firefox.desktop" ];
            "x-scheme-handler/unknown" = [ "firefox.desktop" ];
            "x-scheme-handler/mailto" = [ "thunderbird.desktop" ];
          };

          associations.added = {
            "x-scheme-handler/mailto" = [ "thunderbird.desktop" ];
          };
        };

      };
  };
}
