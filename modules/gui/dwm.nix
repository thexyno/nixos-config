{ inputs, config, lib, pkgs, ... }:
let
  cfg = config.ragon.gui;
  laptop = config.ragon.hardware.laptop.enable;
  username = config.ragon.user.username;
  astart = builtins.concatStringsSep "\n" (map (y: (builtins.concatStringsSep ", " (map (x: "\"" + x + "\"") y)) + ", NULL,") cfg.autostart);
in
{
  config = lib.mkIf cfg.enable {
    environment.variables = {
      _JAVA_AWT_WM_NONREPARENTING = "1";
    };
    services.picom = {
      enable = true;
      vSync = true;
    };

    nixpkgs.overlays = [
      (self: super: {
        dwm = super.dwm.overrideAttrs (oldAttrs: rec {
          prePatch = ''
            sed -i "s@/usr/local@$out@" config.mk
            rm config.h
          '';
          src = inputs.dwm;
          postPatch = "${oldAttrs.postPatch}\n cp ${configFile} config.def.h";
          configFile = pkgs.writeText "config.def.h" ''
             /* See LICENSE file for copyright and license details. */
            
             /* appearance */
             static const unsigned int borderpx  = 1;        /* border pixel of windows */
             static const unsigned int snap      = 32;       /* snap pixel */
             static const int showbar            = 1;        /* 0 means no bar */
             static const int topbar             = 1;        /* 0 means bottom bar */
             static const char *fonts[]          = { "JetBrainsMono Nerd Font:size=10" };
             static const char dmenufont[]       = "JetBrainsMono Nerd Font:size=10";
             static const char col_gray0[]       = "#141414"; // gruvbox bg0
             static const char col_gray1[]       = "#282828"; // gruvbox bg0
             static const char col_gray2[]       = "#3c3836"; // gruvbox bg1
             static const char col_gray3[]       = "#665c54"; // gruvbox bg2
             static const char col_gray4[]       = "#928374"; // gruvbox grey
             static const char col_cyan[]        = "#19cb00"; // gruvbox purple
             static const char *colors[][3]      = {
               /*               fg         bg         border   */
               [SchemeNorm] = { col_gray4, col_gray1, col_gray2 },
               [SchemeSel]  = { col_cyan, col_gray1,  col_gray2  },
             };
            
             typedef struct {
               const char *name;
               const void *cmd;
             } Sp;
             const char *spcmd1[] = {"${cfg.spcmd1cmd}", NULL };
             const char *spcmd2[] = {"${cfg.spcmd2cmd}", NULL };
             // const char *spcmd3[] = {"keepassxc", NULL };
             static Sp scratchpads[] = {
               /* name          cmd  */
               {"${cfg.spcmd1class}",      spcmd1},
               {"${cfg.spcmd2class}",    spcmd2},
             //   {"keepassxc",   spcmd3},
             };
            
             static const char *const autostart[] = {
               ${astart}
               "slstatus", NULL,
               NULL /* terminate */
             };
            
             /* tagging */
             static const char *tags[] = { "1", "2", "3", "4", "5", "6", "7", "8", "9" };
            
             static const Rule rules[] = {
               /* xprop(1):
                *  WM_CLASS(STRING) = instance, class
                *  WM_NAME(STRING) = title
                */
               /* class      instance    title       tags mask     isfloating   monitor */
               { "floating", NULL,       NULL,       0,            1,           -1 },
            //   { "Firefox",  NULL,       NULL,       1 << 8,       0,           -1 },
               { NULL,       "${cfg.spcmd1class}", NULL,       SPTAG(0),     1,           2 },
               { NULL,       "${cfg.spcmd2class}", NULL,      SPTAG(1),     1,           2 },
             };
            
             /* layout(s) */
             static const float mfact     = 0.55; /* factor of master area size [0.05..0.95] */
             static const int nmaster     = 1;    /* number of clients in master area */
             static const int resizehints = 1;    /* 1 means respect size hints in tiled resizals */
            
             static const Layout layouts[] = {
               /* symbol     arrange function */
               { "Tiling",      tile },    /* first entry is default */
               { "Floating",      NULL },    /* no layout function means floating behavior */
               { "Monocle",      monocle },
             };
            
             /* key definitions */
             #define MODKEY Mod4Mask
             #define TAGKEYS(KEY,TAG) \
               { MODKEY,                       KEY,      view,           {.ui = 1 << TAG} }, \
               { MODKEY|ControlMask,           KEY,      toggleview,     {.ui = 1 << TAG} }, \
               { MODKEY|ShiftMask,             KEY,      tag,            {.ui = 1 << TAG} }, \
               { MODKEY|ControlMask|ShiftMask, KEY,      toggletag,      {.ui = 1 << TAG} },
            
             /* helper for spawning shell commands in the pre dwm-5.0 fashion */
             #define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }
            
             /* commands */
             static char dmenumon[2] = "0"; /* component of dmenucmd, manipulated in spawn() */
             static const char *dmenucmd[] =       { "rofi", "-show", "combi", NULL };
             static const char *termcmd[]  =       { "st", NULL };
             static const char *termfloatcmd[]  =  { "st", "-c", "floating", NULL };
             static const char *pulsemixercmd[]  = { "st", "-c", "floating", "pulsemixer", NULL };
             static const char *nnncmd[]  =        { "st", "-c", "floating", "zsh", "-ic", "n;exec zsh", NULL };
             static const char *scrotcmd[]  =      { "sh", "-c", "scrot -s  '%Y-%m-%d_\\$wx\\$h_scrot.png' -e 'mv \\$f ~/Screenshots/; xclip -t image/png -selection clipboard ~/Screenshots/\\$f'", NULL };
             static const char *volupcmd[]  =      { "changeVolume", "+5", NULL };
             static const char *voldowncmd[]  =    { "changeVolume", "-5", NULL };
             static const char *volmutecmd[]  =    { "changeVolume", "mute", NULL };
             static const char *playpausecmd[]  =  { "playerctl", "play-pause", NULL };
             static const char *nextcmd[]  =       { "playerctl", "next", NULL };
             static const char *previouscmd[] =    { "playerctl", "previous", NULL };
             static const char *clipmenucmd[] =    { "clipmenu", NULL };
             static const char *sharenix2cmd[] = { "nextshot", "-a", 0 };
             static const char *sharenix3cmd[] = { "nextshot", "-w", 0 };
             static const char *sharenix4cmd[] = { "nextshot", "-f", 0 };
             static const char *brightnessupcmd[] =   { "xbacklight", "-inc", "5", 0 };
             static const char *brightnessdowncmd[] = { "xbacklight", "-dec", "5", 0 };
            
             static Key keys[] = {
               /* modifier                     key          function        argument */
               { MODKEY,                       XK_p,        spawn,          {.v = dmenucmd } },
               { MODKEY|ShiftMask,             XK_Return,   spawn,          {.v = termcmd } },
               { MODKEY|ShiftMask,             XK_v,        spawn,          {.v = pulsemixercmd } },
               { MODKEY|ShiftMask,             XK_f,        spawn,          {.v = nnncmd } },
               { MODKEY|ControlMask,           XK_Return,   spawn,          {.v = termfloatcmd } },
               { MODKEY|Mod1Mask,                XK_2,         spawn,           {.v = sharenix2cmd } },
               { MODKEY|Mod1Mask,                XK_3,         spawn,           {.v = sharenix3cmd } },
               { MODKEY|Mod1Mask,               XK_4,        spawn,          {.v = sharenix4cmd } },
               { MODKEY|ShiftMask,             XK_c,        spawn,          {.v = clipmenucmd } },
               { 0,                            XK_Print,    spawn,          {.v = scrotcmd } },
               { 0,                            0x1008ff11,  spawn,          {.v = voldowncmd } },
               { 0,                            0x1008ff12,  spawn,          {.v = volmutecmd } },
               { 0,                            0x1008ff13,  spawn,          {.v = volupcmd } },
               { 0,                            0x1008ff14,  spawn,          {.v = playpausecmd } },
               { 0,                            0x1008ff16,  spawn,          {.v = previouscmd } },
               { 0,                            0x1008ff17,  spawn,          {.v = nextcmd } },
               { 0,                            0x1008ff02,  spawn,          {.v = brightnessupcmd } },
               { 0,                            0x1008ff03,  spawn,          {.v = brightnessdowncmd } },
               { MODKEY,                        XK_period,   togglescratch,  {.ui = 0 } },
               { MODKEY,                        XK_minus,     togglescratch,  {.ui = 1 } },
               { MODKEY,                       XK_s,         togglesticky,   {0} },
               { MODKEY,                       XK_b,        togglebar,      {0} },
               { MODKEY,                       XK_j,        focusstack,     {.i = +1 } },
               { MODKEY,                       XK_k,        focusstack,     {.i = -1 } },
               { MODKEY|ShiftMask,             XK_j,        incnmaster,     {.i = +1 } },
               { MODKEY|ShiftMask,             XK_k,        incnmaster,     {.i = -1 } },
             //{ MODKEY,                       XK_h,        setmfact,       {.f = -0.05} },
             //{ MODKEY,                       XK_l,        setmfact,       {.f = +0.05} },
               { MODKEY,                       XK_Return,   zoom,           {0} },
               { MODKEY,                       XK_Tab,      view,           {0} },
               { MODKEY|ShiftMask,             XK_q,        killclient,     {0} },
               { MODKEY,                       XK_t,        setlayout,      {.v = &layouts[0]} },
               { MODKEY,                       XK_f,        setlayout,      {.v = &layouts[1]} },
               { MODKEY,                       XK_m,        setlayout,      {.v = &layouts[2]} },
               { MODKEY,                       XK_space,    setlayout,      {0} },
               { MODKEY|ShiftMask,             XK_space,    togglefloating, {0} },
               { MODKEY,                       XK_0,        view,           {.ui = ~0 } },
               { MODKEY|ShiftMask,             XK_0,        tag,            {.ui = ~0 } },
               { MODKEY,                       XK_h,        focusmon,       {.i = -1 } },
               { MODKEY,                       XK_l,        focusmon,       {.i = +1 } },
               { MODKEY|ShiftMask,             XK_h,        tagmon,         {.i = -1 } },
               { MODKEY|ShiftMask,             XK_l,        tagmon,         {.i = +1 } },
               TAGKEYS(                        XK_1,                        0)
               TAGKEYS(                        XK_2,                        1)
               TAGKEYS(                        XK_3,                        2)
               TAGKEYS(                        XK_4,                        3)
               TAGKEYS(                        XK_5,                        4)
               TAGKEYS(                        XK_6,                        5)
               TAGKEYS(                        XK_7,                        6)
               TAGKEYS(                        XK_8,                        7)
               TAGKEYS(                        XK_9,                        8)
               { MODKEY|ShiftMask,             XK_p,        quit,           {0} },
             };
            
             /* button definitions */
             /* click can be ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin */
             static Button buttons[] = {
               /* click                event mask      button          function        argument */
               { ClkLtSymbol,          0,              Button1,        setlayout,      {0} },
               { ClkLtSymbol,          0,              Button3,        setlayout,      {.v = &layouts[2]} },
               { ClkWinTitle,          0,              Button2,        zoom,           {0} },
               { ClkStatusText,        0,              Button2,        spawn,          {.v = termcmd } },
               { ClkClientWin,         MODKEY,         Button1,        movemouse,      {0} },
               { ClkClientWin,         MODKEY,         Button2,        togglefloating, {0} },
               { ClkClientWin,         MODKEY,         Button3,        resizemouse,    {0} },
               { ClkTagBar,            0,              Button1,        view,           {0} },
               { ClkTagBar,            0,              Button3,        toggleview,     {0} },
               { ClkTagBar,            MODKEY,         Button1,        tag,            {0} },
               { ClkTagBar,            MODKEY,         Button3,        toggletag,      {0} },
             };
          '';
        });
      }
      )
    ];

    services.xserver.displayManager.defaultSession = "none+dwm";
    services.xserver.windowManager.dwm.enable = true;
    environment.systemPackages = with pkgs; [
      playerctl
      (slstatus.overrideAttrs (oldAttrs: rec {
        conf =
          let
            laptopargs = lib.optionalString laptop ''
              { battery_perc,    "BAT: %s | ",           "BAT0" },
              { run_command,    "LIGHT: %s | ",           "cat /sys/class/backlight/intel_backlight/brightness" },
            '';
            nonlaptopargs = lib.optionalString (laptop == false) ''
              { run_command,    "MOUSE: %s | ",           "cat /sys/class/power_supply/hidpp_battery_*/capacity_level | sed 's/Unknown/Charging/'" },
              { disk_free,   "NAS: %s | ",           "/media/data" },
            '';
            templ =
              ''
                /* See LICENSE file for copyright and license details. */
          
                /* interval between updates (in ms) */
                const unsigned int interval = 1000;
          
                /* text to show if no value can be retrieved */
                static const char unknown_str[] = "n/a";
          
                /* maximum output string length */
                #define MAXLEN 2048
          
                /*
                 * function            description                     argument (example)
                 *
                 * battery_perc        battery percentage              battery name (BAT0)
                 *                                                     NULL on OpenBSD/FreeBSD
                 * battery_state       battery charging state          battery name (BAT0)
                 *                                                     NULL on OpenBSD/FreeBSD
                 * battery_remaining   battery remaining HH:MM         battery name (BAT0)
                 *                                                     NULL on OpenBSD/FreeBSD
                 * cpu_perc            cpu usage in percent            NULL
                 * cpu_freq            cpu frequency in MHz            NULL
                 * datetime            date and time                   format string (%F %T)
                 * disk_free           free disk space in GB           mountpoint path (/)
                 * disk_perc           disk usage in percent           mountpoint path (/)
                 * disk_total          total disk space in GB          mountpoint path (/")
                 * disk_used           used disk space in GB           mountpoint path (/)
                 * entropy             available entropy               NULL
                 * gid                 GID of current user             NULL
                 * hostname            hostname                        NULL
                 * ipv4                IPv4 address                    interface name (eth0)
                 * ipv6                IPv6 address                    interface name (eth0)
                 * kernel_release      `uname -r`                      NULL
                 * keyboard_indicators caps/num lock indicators        format string (c?n?)
                 *                                                     see keyboard_indicators.c
                 * keymap              layout (variant) of current     NULL
                 *                     keymap
                 * load_avg            load average                    NULL
                 * netspeed_rx         receive network speed           interface name (wlan0)
                 * netspeed_tx         transfer network speed          interface name (wlan0)
                 * num_files           number of files in a directory  path
                 *                                                     (/home/foo/Inbox/cur)
                 * ram_free            free memory in GB               NULL
                 * ram_perc            memory usage in percent         NULL
                 * ram_total           total memory size in GB         NULL
                 * ram_used            used memory in GB               NULL
                 * run_command         custom shell command            command (echo foo)
                 * separator           string to echo                  NULL
                 * swap_free           free swap in GB                 NULL
                 * swap_perc           swap usage in percent           NULL
                 * swap_total          total swap size in GB           NULL
                 * swap_used           used swap in GB                 NULL
                 * temp                temperature in degree celsius   sensor file
                 *                                                     (/sys/class/thermal/...)
                 *                                                     NULL on OpenBSD
                 *                                                     thermal zone on FreeBSD
                 *                                                     (tz0, tz1, etc.)
                 * uid                 UID of current user             NULL
                 * uptime              system uptime                   NULL
                 * username            username of current user        NULL
                 * vol_perc            OSS/ALSA volume in percent      mixer file (/dev/mixer)
                 *                                                     NULL on OpenBSD
                 * wifi_perc           WiFi signal in percent          interface name (wlan0)
                 * wifi_essid          WiFi ESSID                      interface name (wlan0)
                 */
                static const struct arg args[] = {
                  /* function format          argument */
                  ${laptopargs}
                  ${nonlaptopargs}
                  { run_command, "AUDIO: %s | ",           "pulsemixer --list-sinks | rg Default | sed -z 's/^.*Name: //g;s/,.*//g'; echo -n ' '; (pulsemixer --get-mute | rg 1 && echo -n 'Muted') || pulsemixer --get-volume | awk '{print($1,\"%\")}'" },
                  { ram_free,    "RAM: %s | ",           NULL },
                  { load_avg,    "LOAD: %s | ",           NULL },
                  { disk_free,   "SSD: %s | ",           "/nix" },
                  { datetime,    "%s",           "%F %T" },
                };
              '';
          in
          templ;
        configFile = (pkgs.writeText "config.def.h" conf);
        preBuild = "cp ${configFile} config.def.h";

      }))
      scrot
      # stuff needed for nextshot:
      imagemagick
      slop
      bc
      xclip
      xdotool
      yad
      libnotify
    ];

  };
}
