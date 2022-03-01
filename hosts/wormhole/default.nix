{ config, inputs, pkgs, lib, ... }:
{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
    "${inputs.nixos-hardware}/raspberry-pi/4/default.nix"
    ./router.nix
  ];
  nixpkgs.overlays = [
    (final: super: {
      makeModulesClosure = x:
        super.makeModulesClosure (x // { allowMissing = true; });
    })
  ];
  boot.loader.systemd-boot.enable = false;
  boot.kernelPackages = pkgs.linuxPackages_rpi4;
  boot.supportedFilesystems = lib.mkForce [ "reiserfs" "vfat" "zfs" "ext4" ]; # we dont need zfs here
  boot.inird.supportedFilesystems = lib.mkForce [ "reiserfs" "vfat" "zfs" "ext4" ]; # we dont need zfs here
  networking.hostId = "eec43f51";
  # networking.usePredictableInterfaceNames = false;
  documentation.enable = false;
  documentation.nixos.enable = false;

  nix = {
    autoOptimiseStore = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    # Free up to 1GiB whenever there is less than 100MiB left.
    extraOptions = ''
      min-free = ${toString (100 * 1024 * 1024)}
      max-free = ${toString (1024 * 1024 * 1024)}
    '';
  };
  powerManagement.cpuFreqGovernor = "ondemand";

  # Assuming this is installed on top of the disk image.
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  ragon.networking.router.enable = true;
  ragon.services.ssh.enable = true;
  ragon.cli.enable = true;
  ragon.cli.maximal = false;
  services.lorri.enable = false;
  ragon.services.ddns.enable = true;
  ragon.services.tailscale.enable = true;
  ragon.services.nginx.enable = true;
  services.nginx.virtualHosts."h.hailsatan.eu" = {
    forceSSL = true;
    useACMEHost = "hailsatan.eu";
    extraConfig = ''
      proxy_buffering off;
    '';
    locations."/".proxyPass = "http://10.0.0.20:8123";
    locations."/".proxyWebsockets = true;
  };
  services.nginx.virtualHosts."hailsatan.eu" = {
    forceSSL = true;
    useACMEHost = "hailsatan.eu";
    root = pkgs.runCommand "homepage" { } ''
      mkdir -p $out
      echo "Hail Satan" > $out/index.html
      echo "User-agent: *" > $out/robots.txt
      echo "Disallow: /" >> $out/robots.txt
    '';
  };
  services.nginx.virtualHosts."j.hailsatan.eu" = {
    forceSSL = true;
    useACMEHost = "hailsatan.eu";
    extraConfig = ''
      proxy_buffering off;
    '';
    locations."/".proxyPass = "https://j.hailsatan.eu";
    locations."/".proxyWebsockets = true;
  };

  users.users.root.openssh.autorizedKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDiKJEYNUU+ZpbOyJf9k9ZZdTTL0qLiZ6fXEBVCjNfas"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIkFgHr6OMwsnGhdG4TwKdthlJC/B9ELqZfrmJ9Sf7qk"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCJVa1zAjR6stS4qIEysQbR9n0/AV2h62QRfsRvNfQiL19ExKFR7ZHaUFBr6jnGjzl5eyK0DtwZMlyaDlTR/AXiTZHJrvEPL1lna42wK252uZb66DXAG23L+iFeXySq3f+a6Prw8NU3HvIvC/YkEYwjjbqPKEjvnIHd2dJ1FZ9T9FeoKup3nMWYGDRqrja8NcRwCY9OpPd3ZKZJlNJcPfbfAipGAuQ6EGgGi0GzqoYP9OqZx9PBQQEY7a5+cUgYYEI75NJNuk4/WBm8fkFKrcOmvhTOEb90kbNmpHusDOrFEo8LATdpmJSG013DpPb1W7pMxMq+YgFF4INqIxrhBGht"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH8RjUQ6DDDDgsVbqq+6zz1q6cBkus/BLUGa9JoWsqB4"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCWwrrROqkBEZi8t7Czu1jDDJjSqomGXx7dhIx73GTb3bBlgThqUSsrG+NpP9mxNl4sYgmJYQ9idpUW/RTX3/sXBvNQi4rOqv9z1qdEyzF86CcyWGk4f+D2hJffLlcIbvbDCJ92PF+k5NbH+PC/yVZKSIRC3ENBHf38l8n25ABuBcpCI16bPCIbqbpekqStXClug//uAyENuS6+orHFQg3muUihEedEhJly1QAfDhOzZRlBxTGQcDvZA/XMaIyjAqbXaNVRsDLmKezm/Dg5M3jMIRxApUd9hcuZlfemxUgD0qqnJSTahb9rMxUKk5jdY95EthAp0s2e6tc2O76sYPqb"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH99QITZa3hSa+7sMo4M5IC5mXWEjsRqXUSaYKKRyQfE"
  ];
}
