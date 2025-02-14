{
  description = "ragons nix/nixos configs";
  inputs = {
    # base imports
    utils.url = "github:numtide/flake-utils";

    ## nixos/nix-darwin dependencies
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-24.05-darwin";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    agenix.url = "github:ryantm/agenix/main";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    impermanence.url = "github:nix-community/impermanence";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.91.1-2.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # programs
    xynoblog.url = "github:thexyno/blog";
    xynoblog.inputs.nixpkgs.follows = "nixpkgs";
    x.url = "github:thexyno/x";
    x.inputs.nixpkgs.follows = "nixpkgs";
    helix.url = "github:SofusA/helix-pull-diagnostics/pull-diagnostics";
    wired.inputs.nixpkgs.follows = "nixpkgs";
    wired.url = "github:Toqozz/wired-notify";
    roslyn-language-server.url = "github:sofusa/roslyn-language-server";
    roslyn-language-server.inputs.nixpkgs.follows = "nixpkgs";
    zen-browser.url = "github:0xc000022070/zen-browser-flake";


    kmonad = {
      url = "git+https://github.com/jokesper/kmonad?dir=nix&ref=feat-tap-overlap";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ## editor stuff
    # nixd.url = "github:nix-community/nixd";
    # nixd.inputs.nixpkgs.follows = "nixpkgs";


    ## vim
    # nnn-nvim.url = "github:luukvbaal/nnn.nvim";
    # nnn-nvim.flake = false;
    # notify-nvim.url = "github:rcarriga/nvim-notify";
    # notify-nvim.flake = false;
    # noice-nvim.url = "github:folke/noice.nvim";
    # noice-nvim.flake = false;

    # ## zsh
    # zsh-completions.url = "github:zsh-users/zsh-completions";
    # zsh-completions.flake = false;
    # zsh-syntax-highlighting.url = "github:zsh-users/zsh-syntax-highlighting/master";
    # zsh-syntax-highlighting.flake = false;
    # zsh-vim-mode.url = "github:softmoth/zsh-vim-mode";
    # zsh-vim-mode.flake = false;
    # agkozak-zsh-prompt.url = "github:agkozak/agkozak-zsh-prompt";
    # agkozak-zsh-prompt.flake = false;

    # ## xonsh
    # xonsh-fish-completer.url = "github:xonsh/xontrib-fish-completer";
    # xonsh-fish-completer.flake = false;
    # xonsh-direnv.url = "github:74th/xonsh-direnv";
    # xonsh-direnv.flake = false;

    ## hammerspoon
    miro.url = "github:miromannino/miro-windows-manager";
    miro.flake = false;
    spoons.url = "github:Hammerspoon/Spoons";
    spoons.flake = false;



    #other dependencies
    pandoc-latex-template.url = "github:Wandmalfarbe/pandoc-latex-template";
    pandoc-latex-template.flake = false;

  };

  outputs =
    inputs @ { self
    , nixpkgs
    , nixpkgs-darwin
    , nixpkgs-master
    , agenix
    , home-manager
    , impermanence
    , darwin
    , utils
    , xynoblog
    # , lolpizza
    , lix-module
    , kmonad
    , wired
    , x
    , ...
    }:
    let
      extraSystems = [ ];
      lib = nixpkgs.lib.extend (self: super: {
        my = import ./lib { inherit inputs; lib = self; };
      });

      overlays = [
        self.overlays.default
        wired.overlays.default
      ];
      genPkgsWithOverlays = system: import nixpkgs {
        inherit system overlays;
        config.allowUnfree = true;
      };
      genDarwinPkgsWithOverlays = system: import nixpkgs-darwin {
        inherit system overlays;
        config.allowUnfree = true;
      };


      rev = if (lib.hasAttrByPath [ "rev" ] self.sourceInfo) then self.sourceInfo.rev else "Dirty Build";

      nixosSystem = system: extraModules: hostName:
        let
          pkgs = genPkgsWithOverlays system;
        in
        nixpkgs.lib.nixosSystem
          rec {
            inherit system;
            specialArgs = { inherit lib inputs; };
            modules = [
              lix-module.nixosModules.default
              agenix.nixosModules.age
              impermanence.nixosModules.impermanence
              home-manager.nixosModules.home-manager
              kmonad.nixosModules.default
              xynoblog.nixosModule
              # lolpizza.nixosModule
              x.nixosModule
              ({ config, ... }: lib.mkMerge [{
                nixpkgs.pkgs = pkgs;
                nixpkgs.overlays = overlays;
                networking.hostName = hostName;
                system.configurationRevision = rev;
                services.getty.greetingLine =
                  "<<< Welcome to ${config.system.nixos.label} @ ${rev} - Please leave \\l >>>";
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.extraSpecialArgs = { inherit inputs; };
              }])
              ./nixos-common.nix
            ] ++ extraModules;
          };
      darwinSystem = system: extraModules: hostName:
        let
          pkgs = genDarwinPkgsWithOverlays system;
        in
        darwin.lib.darwinSystem
          {
            inherit system;
            specialArgs = { inherit lib inputs self darwin; };
            modules = [
              home-manager.darwinModules.home-manager
              {
                nixpkgs.overlays = overlays;
                networking.hostName = hostName;
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.extraSpecialArgs = { inherit inputs pkgs; };
              }
              ./darwin-common.nix
              lix-module.nixosModules.default
            ] ++ extraModules;
          };

      processConfigurations = lib.mapAttrs (n: v: v n);


    in
    {
      lib = lib.my;
      overlays.default = final: prev: {
        unstable = import nixpkgs-master {
          system = prev.system;
          config.allowUnfree = true;
        };
        my = self.packages."${prev.system}";
      };
      # nixosModules = lib.my.mapModulesRec ./nixos-modules import;
      # darwinModules = lib.my.mapModulesRec ./darwin-modules import;

      nixosConfigurations = processConfigurations {
        picard = nixosSystem "x86_64-linux" [ ./hosts/picard/default.nix ];
        ds9 = nixosSystem "x86_64-linux" [ ./hosts/ds9/default.nix ];

        voyager = nixosSystem "x86_64-linux" [ ./hosts/voyager/default.nix ];
        theseus = nixosSystem "x86_64-linux" [ ./hosts/theseus/default.nix ];
      };
      darwinConfigurations = processConfigurations {
        daedalus = darwinSystem "aarch64-darwin" [ ./hosts/daedalus/default.nix ];
      };

    } // utils.lib.eachDefaultSystem (system:
    let pkgs = nixpkgs.legacyPackages.${system}; in
    {
      devShell = pkgs.mkShell {
        buildInputs = with pkgs; [ lefthook nixpkgs-fmt inputs.agenix.packages.${system}.agenix ];
      };
      packages = lib.my.mapModules ./packages (p: pkgs.callPackage p { inputs = inputs; });
    });
}
