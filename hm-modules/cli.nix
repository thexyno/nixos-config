{ inputs, config, lib, pkgs, ... }:
{

  home.stateVersion = lib.mkDefault "22.05";
  home.packages = with pkgs; [
    my.scripts
    jq
    nnn
    bat
    htop
    eza
    curl
    fd
    file
    git
    neofetch
    ripgrep
    direnv # needed for lorri
    unzip
    pv
    killall
    yt-dlp
    aria2
  ];
  home.shellAliases = {
    v = "nvim";
    c = "code";
    vim = "nvim";
    gpl = "git pull";
    gp = "git push";
    gd = "git diff";
    lg = "lazygit";
    gc = "git commit -v";
    kb = "git commit -m \"\$(curl -s http://whatthecommit.com/index.txt)\"";
    gs = "git status -v";
    gfc = "git fetch && git checkout";
    gl = "git log --graph";
    l = "eza -la --git";
    la = "eza -la --git";
    ls = "eza";
    ll = "eza -l --git";
    cat = "bat";
    p = "cd ~/proj";
    ytl = ''yt-dlp -f "bv*+mergeall[vcodec=none]" --audio-multistreams'';
  };

  programs = {
    bat = {
      enable = true;
      config.theme = "gruvbox-dark";
    };
    git = {
      enable = true;
      lfs.enable = true;

      # Default configs
      extraConfig = {
        commit.gpgSign = true;
        gpg.format = "ssh";

        user.name = "Lucy Hochkamp";
        user.email = "git@xyno.systems";
        user.signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIuwQJY0H/fdu1UmGXAut7VfcvAk2Dm78tJpkyyv2in2";

        # Set default "git pull" behaviour so it doesn't try to default to
        # either "git fetch; git merge" (default) or "git fetch; git rebase".
        pull.ff = "only";
      };
    };
    # Htop configurations
    htop = {
      enable = true;
      settings = {
        hide_userland_threads = true;
        highlight_base_name = true;
        shadow_other_users = true;
        show_program_path = false;
        tree_view = false;
      };
    };

  };
}

