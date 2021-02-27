
{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    jetbrains-mono nerdfonts kitty
  ];
}
