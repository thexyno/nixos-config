{ pkgs, lib, ... }:
with lib;
with pkgs;
st.overrideAttrs ( oldAttrs: rec {
  buildInputs = oldAttrs.buildInputs ++ [ harfbuzz ];
  patches = [
      # scrollback
      (fetchpatch {
        url = "https://st.suckless.org/patches/scrollback/st-scrollback-0.8.4.diff";
        sha256 = "0i0fav13sxnsydpllny26139gnzai66222502cplh18iy5fir3j1";
      })
      # ligatures patch
      (fetchpatch {
        url = "https://st.suckless.org/patches/ligatures/0.8.3/st-ligatures-scrollback-20200430-0.8.3.diff";
        sha256 = "0c7g3wcacxlrs7v0j2drgqg2wksggjicsym6pqawca8fi15bkbfq";
      })
      # curly underline
      (fetchpatch {
        url = "https://st.suckless.org/patches/undercurl/st-undercurl-0.8.4.diff";
        sha256 = "1fz8l0fyid5b39kkiwkfs0bnhm4v7s2ybhakvkvshwfys6k6sj3x";
      })

  ];
  configFile = writeText "config.def.h" (builtins.readFile ./st/config.h);
  postPatch = "${oldAttrs.postPatch}\n cp ${configFile} config.def.h";

})
