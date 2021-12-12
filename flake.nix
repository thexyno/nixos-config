{
  description = "OS level Autism, Goblins";

  inputs = {
    # nix inputs
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    agenix.url = "github:ryantm/agenix/main";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    impermanence.url = "github:nix-community/impermanence";
    impermanence.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    neovim-nightly-overlay.inputs.nixpkgs.follows = "nixpkgs";

    # Used for Deployment to servers
    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";

    rnix-lsp.url = "github:nix-community/rnix-lsp";
    rnix-lsp.inputs.nixpkgs.follows = "nixpkgs";

    st.url = "github:ragon000/st/ragon";
    st.inputs.nixpkgs.follows = "nixpkgs";

    # other inputs

    ## needed for shell.nix
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    ## applications
    dwm.url = "github:ragon000/dwm";
    dwm.flake = false;
    pandoc-latex-template.url = "github:Wandmalfarbe/pandoc-latex-template";
    pandoc-latex-template.flake = false;
    pandocode.url = "github:nzbr/pandocode";
    pandocode.flake = false;
    cnping.url = "github:cnlohr/cnping";
    cnping.flake = false;
    pridecat.url = "github:lunasorcery/pridecat";
    pridecat.flake = false;
    pulse-launch.url = "github:ragon000/pulse-launch";
    pulse-launch.flake = false;
    i3ipc-dynamic-tiling.url = "github:chlyz/i3ipc-dynamic-tiling";
    i3ipc-dynamic-tiling.flake = false;

    ## vim
    coc-nvim.url = "github:neoclide/coc.nvim/release";
    coc-nvim.flake = false;
    nnn-vim.url = "github:mcchrish/nnn.vim";
    nnn-vim.flake = false;
    dart-vim.url = "github:dart-lang/dart-vim-plugin/master";
    dart-vim.flake = false;
    vim-pandoc-live-preview.url = "github:ragon000/vim-pandoc-live-preview/master";
    vim-pandoc-live-preview.flake = false;
    orgmode-nvim.url = "github:kristijanhusak/orgmode.nvim";
    orgmode-nvim.flake = false;

    ## zsh
    zsh-completions.url = "github:zsh-users/zsh-completions";
    zsh-completions.flake = false;
    zsh-syntax-highlighting.url = "github:zsh-users/zsh-syntax-highlighting/master";
    zsh-syntax-highlighting.flake = false;
    zsh-vim-mode.url = "github:softmoth/zsh-vim-mode";
    zsh-vim-mode.flake = false;
    agkozak-zsh-prompt.url = "github:agkozak/agkozak-zsh-prompt";
    agkozak-zsh-prompt.flake = false;

    # sway



  };


  outputs = inputs @ { self, nixpkgs, nixpkgs-master, neovim-nightly-overlay, st, deploy-rs, ... }:
    let
      inherit (lib.my) mapModules mapModulesRec mapHosts mapNodes;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      forAllSystems = f: lib.genAttrs systems (system: f system);
      mkPkgs = system: pkgs: extraOverlays: import pkgs {
        # apply config and overlays to following pkgs
        inherit system;
        config.allowUnfree = true; # fuck rms and his cult
        overlays = extraOverlays;
      };
      pkgs = system: mkPkgs system nixpkgs [ self.overlay neovim-nightly-overlay.overlay ];
      pkgs' = system: mkPkgs system nixpkgs-master [ ];
      pkgsBySystem = forAllSystems pkgs;

      lib = nixpkgs.lib.extend # extend lib with the stuff in ./lib
        (self: super: { my = import ./lib { inherit pkgsBySystem inputs; lib = self; }; });

    in
    {
      lib = lib.my; # idk


      overlay =
        final: prev: {
          unstable = pkgs' prev.system;
          st-ragon = st.packages."${prev.system}".st;
          pubkeys = import ./data/pubkeys.nix;
          my = self.packages."${prev.system}";
        };
      #overlays =
      #  mapModules ./overlays import; # placeholder for when I add my own overlays

      packages =
        let
          mkPackages = system: mapModules ./packages (p: pkgsBySystem.${system}.callPackage p { inputs = inputs; }); # load my own packages (pandocode)
        in
        forAllSystems mkPackages;

      nixosModules =
        { conf = import ./.; } // mapModulesRec ./modules import; # load all the juicy modules

      nixosConfigurations =
        mapHosts ./hosts { };

      deploy = {
        nodes = mapNodes ./hosts { out = self.nixosConfigurations; };
        user = "root";
        sshUser = "ragon";
      };

      # \deploy-rs
      #   This is highly advised, and will prevent many possible mistakes
      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;

      devShell =
        let
          mkS = system:
            let
              p = pkgs system;
            in
            p.mkShell {
              buildInputs = [ p.lefthook p.nixpkgs-fmt ];
            };
        in
        forAllSystems mkS;
      templates = {
        full = {
          path = ./.;
          description = "Full autism";
        };
        minimal = {
          path = ./templates/minimal;
          description = "Full autism, muhnimal bloat";
        };
      };
      defaultTemplate = self.templates.minimal;

    };

}
