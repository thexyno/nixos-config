{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) concatStringsSep concatMapStringsSep mapAttrsToList;
  lmsConfig = {
    api-subsonic-support-user-password-auth = true;
    behind-reverse-proxy = true;
    authentication-backend = "http-headers";
    http-headers-login-field = "X-Remote-User";
    working-dir = "/var/lib/lms";
    scanner-skip-duplicate-mbid = true;
    ffmpeg-file = "${pkgs.ffmpeg-full}/bin/ffmpeg";
    wt-resources = "${pkgs.wt}/share/Wt/resources";
    docroot = "${pkgs.lms}/share/lms/docroot/;/resources,/css,/images,/js,/favicon.ico";
    approot = "${pkgs.lms}/share/lms/approot";
    # log-min-severity = "debug";
    trusted-proxies = ["127.0.0.1" "::1"];
    # db-show-queries = true;
  };
  writeVal =
    x:
    if builtins.typeOf x == "string" then
      ''"${x}"''
    else if builtins.typeOf x == "list" then
      ''(${(concatMapStringsSep ",\n" writeVal x)})''
    else if builtins.typeOf x == "bool" then
      (if x then "true" else "false")
    else
      (writeVal (toString x));
  lmsConfigFile = pkgs.writeText "lms.conf" (
    (concatStringsSep "\n" (mapAttrsToList (n: v: "${n} = ${writeVal v};") lmsConfig)) + "\n"
  );
in
{
  systemd.services.lms = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    environment.OMP_THREAD_LIMIT = "1";
    serviceConfig = {
      DynamicUser = true;
      ExecStart = ''
        ${pkgs.lms}/bin/lms ${lmsConfigFile}
      '';
      Group = "users";
      StateDirectory = "lms";
      RuntimeDirectory = "lms";
      WorkingDirectory = "/var/lib/lms";
      RootDirectory = "/run/lms";
      ReadWritePaths = "";
      BindReadOnlyPaths = [
        "${config.security.pki.caBundle}:/etc/ssl/certs/ca-certificates.crt"
        builtins.storeDir
        "/etc"
        "/data/media/beets/music"
      ]
      ++ lib.optionals config.services.resolved.enable [
        "/run/systemd/resolve/stub-resolv.conf"
        "/run/systemd/resolve/resolv.conf"
      ];
      CapabilityBoundingSet = "";
      RestrictAddressFamilies = [
        "AF_UNIX"
        "AF_INET"
        "AF_INET6"
      ];
      RestrictNamespaces = true;
      PrivateDevices = true;
      PrivateUsers = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      SystemCallArchitectures = "native";
      SystemCallFilter = [
        "@system-service"
        "~@privileged"
      ];
      RestrictRealtime = true;
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      UMask = "0066";
      ProtectHostname = true;

    };

  };

  ragon.persist.extraDirectories = [
    {
      directory = "/var/lib/private/lms";
      mode = "0700";
      defaultPerms.mode = "0700";
    }
  ];
}
