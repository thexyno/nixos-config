{ lib, nnn, stdenv , ... }:
nnn.overrideAttrs (oldAttrs: rec {
  withNerdIcons = true;
  conf = builtins.readFile ./nnn/nnn.h;
})
