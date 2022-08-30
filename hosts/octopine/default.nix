# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, inputs, pkgs, lib, ... }:
with lib;
let
  compressLargeArtifacts = false;
in
{
  imports =
    [
    ];

  services.octoprint = {
    enable = true;
    plugins = plugins: with plugins; [ telegram ];
  };

  mobile.boot.stage-1.kernel.modular = true;
  mobile.generatedFilesystems.rootfs = {
    type = "ext4";
    label = "NIXOS_SYSTEM";
    id = "44444444-4444-4444-8888-888888888888";
    populateCommands =
      let
        closureInfo = pkgs.buildPackages.closureInfo { rootPaths = config.system.build.toplevel; };
      in
      ''
        mkdir -p ./nix/store
        echo "Copying system closure..."
        while IFS= read -r path; do
          echo "  Copying $path"
          cp -prf "$path" ./nix/store
        done < "${closureInfo}/store-paths"
        echo "Done copying system closure..."
        cp -v ${closureInfo}/registration ./nix-path-registration
      '';

    # Give some headroom for initial mounting.
    extraPadding = pkgs.imageBuilder.size.MiB 600; # without this much of a padding inodes are too small for some reason

    # FIXME: See #117, move compression into the image builder.
    # Zstd can take a long time to complete successfully at high compression
    # levels. Increasing the compression level could lead to timeouts.
    postProcess = optionalString compressLargeArtifacts ''
      (PS4=" $ "; set -x
      PATH="$PATH:${buildPackages.zstd}/bin"
      cd $out
      ls -lh
      time zstd -10 --rm "$filename"
      ls -lh
      )
    '' + ''
      (PS4=" $ "; set -x
      mkdir $out/nix-support
      cat <<EOF > $out/nix-support/hydra-build-products
      file rootfs${optionalString compressLargeArtifacts "-zstd"} $out/$filename${optionalString compressLargeArtifacts ".zst"}
      EOF
      )
    '';

    zstd = compressLargeArtifacts;
  };

  mobile.boot.stage-1.kernel.additionalModules = [ "ftdi_sio" ];
  networking.wireless.enable = true;
  networking.useDHCP = true;
  networking.networkmanager.enable = mkForce false;
  services.mjpg-streamer.enable = true;
  services.mjpg-streamer.inputPlugin = "input_uvc.so -d /dev/video1 -r 640x480 -f 15 -u";
  services.xserver.desktopManager.phosh.enable = true;
  services.xserver.desktopManager.phosh.user = "ragon";
  services.xserver.desktopManager.phosh.group = "wheel";
  services.xserver.displayManager.autoLogin.user = "ragon";
  hardware.opengl.enable = true;
  environment.systemPackages = [ pkgs.epiphany ];

  security.sudo.wheelNeedsPassword = false;
  networking.firewall.allowedTCPPorts = [ 5000 5050 ];

  ragon = {
    cli.enable = true;
    user.enable = true;
    system.security.enable = false;

    services = {
      ssh.enable = true;
    };
  };
}
