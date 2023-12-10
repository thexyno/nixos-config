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
    lorri
    fzf
    git
    neofetch
    ripgrep
    direnv # needed for lorri
    unzip
    pv
    killall
    lefthook
    yt-dlp
    aria2
    libqalculate
  ];
  home.shellAliases = {
    v = "nvim";
    vim = "nvim";
    gpl = "git pull";
    gp = "git push";
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
    pd = "cd ~/proj/devsaur";
  };

  programs = {
    # gpg = {
    #   enable = true;
    #   settings = {
    #     cert-digest-algo = "SHA512";
    #     charset = "utf-8";
    #     default-preference-list = "SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed";
    #     auto-key-retrieve = true;
    #     fixed-list-mode = true;
    #     keyserver = "hkps://keyserver.ubuntu.com:443";
    #     list-options = [ "show-uid-validity" "show-unusable-subkeys" ];
    #     no-comments = true;
    #     no-emit-version = true;
    #     no-greeting = true;
    #     no-symkey-cache = true;
    #     personal-cipher-preferences = "AES256 AES192 AES";
    #     personal-compress-preferences = "ZLIB BZIP2 ZIP Uncompressed";
    #     personal-digest-preferences = "SHA512 SHA384 SHA256";
    #     require-cross-certification = true;
    #     s2k-cipher-algo = "AES256";
    #     s2k-digest-algo = "SHA512";
    #     throw-keyids = true;
    #     use-agent = true;
    #     verbose = true;
    #     verify-options = "show-uid-validity";
    #     with-fingerprint = true;
    #     with-key-origin = true;
    #   };
    # };
    bat = {
      enable = true;
      config.theme = "gruvbox-dark";
    };
    fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultOptions = [
        "--height 40%"
        "--layout=reverse"
        "--border"
        "--inline-info"
      ];
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

