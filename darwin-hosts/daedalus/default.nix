{ pkgs, inputs, lib, ... }:
with lib;
with lib.my;
{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget

  imports = [
    "${inputs.home-manager}/nix-darwin"
  ];

  home-manager.users.ragon = {
    imports = mapModulesRec' ../../hm-modules (x: x);
    programs.home-manager.enable = true;
    home.stateVersion = "21.11";
  };
  
  

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  nix.package = pkgs.nixFlakes;
}
