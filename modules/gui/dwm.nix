{ inputs, config, lib, pkgs, ... }:
let
  cfg = config.ragon.gui;
  laptop = config.ragon.hardware.laptop.enable;
  username = config.ragon.user.username;
  astart = builtins.concatStringsSep "\n" (map (y: (builtins.concatStringsSep ", " (map (x: "\"" + x + "\"") y)) + ", NULL,") cfg.autostart);
  dwmblocks = pkgs.dwmblocks.overrideAttrs (oldAttrs: rec {
    postPatch = "${oldAttrs.postPatch}\n cp ${configFile} blocks.def.h";
    configFile = ''
      static const Block blocks[] = {
      	/*Icon*/	/*Command*/		/*Update Interval*/	/*Update Signal*/
        ${lib.optionalString laptop ''
          {"BAT: ", "${pkgs.acpi}/bin/acpi | cut -f3-", 15, 0 },
          {"LIGHT:", "${pkgs.acpilight}/bin/xbacklight -get", 15, 0 },
        ''}
        ${lib.optionalString (laptop == false) ''
          {"MOUSE", "cat /sys/class/power_supply/hidpp_battery_*/capacity_level | sed 's/Unknown/Charging/'", 120, 0 },
      	  {"NAS:", "df --output=avail -h /media/data | awk '/G/ {print($1)}'",	30,		0},
        ''}

      	{"AUDIO:", "pulsemixer --list-sinks | grep Default | sed -z 's/^.*Name: //g;s/,.*//g'; echo -n ' '; (pulsemixer --get-mute | rg 1 && echo -n 'Muted') || pulsemixer --get-volume | awk '{print($1,\"%\")}'",	15,		1},
      	{"RAM:", "free -h | awk '/^Mem/ { print $3\"/\"$2 }' | sed s/i//g",	15,		0},
      	{"LOAD:", "cat /proc/loadavg | awk '{print($1 " " $2 " " $3)}'",	10,		0},

      	{"SSD:", "df --output=avail -h /nix | awk '/G/ {print($1)}'",	30,		0},
      	{"", "date '+%F %T'",					1,		0},
      };
      static char delim[] = " | ";
      static unsigned int delimLen = 5;
    '';

  });
in
{
  options.ragon.gui.dwm.enable = lib.mkEnableOption "Enables ragons Dwm stuff";
  config = lib.mkIf cfg.dwm.enable {
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
               "${pkgs.autorandr}/bin/autorandr", "-c", NULL,
               ${astart}
               "dwmblocks", NULL,
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
             static const char *filemanagercmd[]  =        { "${pkgs.dolphin}/bin/dolphin", NULL };
             static const char *scrotcmd[]  =      { "sh", "-c", "${pkgs.spectacle}/bin/spectacle -r", NULL };
             static const char *volupcmd[]  =      { "sh", "-c" "${pkgs.ponymix}/bin/ponymix -N increase 5; pkill dwmblocks -1", NULL };
             static const char *voldowncmd[]  =      { "sh", "-c" "${pkgs.ponymix}/bin/ponymix -N decrease 5; pkill dwmblocks -1", NULL };
             static const char *volmutecmd[]  =      { "sh", "-c" "${pkgs.ponymix}/bin/ponymix -N toggle; pkill dwmblocks -1", NULL };
             static const char *playpausecmd[]  =  { "playerctl", "play-pause", NULL };
             static const char *nextcmd[]  =       { "playerctl", "next", NULL };
             static const char *previouscmd[] =    { "playerctl", "previous", NULL };
             static const char *brightnessupcmd[] =   { "xbacklight", "-inc", "5", 0 };
             static const char *brightnessdowncmd[] = { "xbacklight", "-dec", "5", 0 };
            
             static Key keys[] = {
               /* modifier                     key          function        argument */
               { MODKEY,                       XK_p,        spawn,          {.v = dmenucmd } },
               { MODKEY|ShiftMask,             XK_Return,   spawn,          {.v = termcmd } },
               { MODKEY|ShiftMask,             XK_v,        spawn,          {.v = pulsemixercmd } },
               { MODKEY|ShiftMask,             XK_f,        spawn,          {.v = filemanagercmd } },
               { MODKEY|ControlMask,           XK_Return,   spawn,          {.v = termfloatcmd } },
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
    environment.systemPackages = [
      pkgs.playerctl
      dwmblocks
    ];

  };
}
