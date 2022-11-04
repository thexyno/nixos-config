{
  description = "ragons nix/nixos configs";
  inputs = {
    # base imports
    utils.url = "github:numtide/flake-utils";

    ## nixos/nix-darwin dependencies
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    agenix.url = "github:ryantm/agenix/main";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    impermanence.url = "github:nix-community/impermanence";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    # programs
    xynoblog.url = "github:thexyno/blog";
    xynoblog.inputs.nixpkgs.follows = "nixpkgs";
    x.url = "github:thexyno/x";
    x.inputs.nixpkgs.follows = "nixpkgs";

    ## editor stuff
    rnix-lsp.url = "github:nix-community/rnix-lsp";
    rnix-lsp.inputs.nixpkgs.follows = "nixpkgs";

    ## emacs
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    emacs-overlay.inputs.nixpkgs.follows = "nixpkgs";

    ## vim
    nnn-vim.url = "github:mcchrish/nnn.vim";
    nnn-vim.flake = false;

    ## zsh
    zsh-completions.url = "github:zsh-users/zsh-completions";
    zsh-completions.flake = false;
    zsh-syntax-highlighting.url = "github:zsh-users/zsh-syntax-highlighting/master";
    zsh-syntax-highlighting.flake = false;
    zsh-vim-mode.url = "github:softmoth/zsh-vim-mode";
    zsh-vim-mode.flake = false;
    agkozak-zsh-prompt.url = "github:agkozak/agkozak-zsh-prompt";
    agkozak-zsh-prompt.flake = false;


    #other dependencies
    pandoc-latex-template.url = "github:Wandmalfarbe/pandoc-latex-template";
    pandoc-latex-template.flake = false;

    ## octoprint
    octoprint-telegram.url = "github:fabianonline/OctoPrint-Telegram";
    octoprint-telegram.flake = false;
    octoprint-spoolmanager.url = "github:OllisGit/OctoPrint-SpoolManager";
    octoprint-spoolmanager.flake = false;

    ## mail
    private.url = "github:thexyno/nixos-config-private-dummy";
    private.flake = false;

  };

  outputs =
    inputs @ { self
    , nixpkgs
    , nixpkgs-master
    , agenix
    , home-manager
    , impermanence
    , darwin
    , utils
    , emacs-overlay
    , xynoblog
    , x
    , ...
    }:
    let
      extraSystems = [ ];
      lib = nixpkgs.lib.extend (self: super: {
        my = import ./lib { inherit inputs; lib = self; };
      });

      genPkgs = system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      overlays = [
        self.overlays.default
        emacs-overlay.overlay
      ];
      genPkgsWithOverlays = system: import nixpkgs {
        inherit system overlays;
        config.allowUnfree = true;
      };


      hmConfig = { hm, pkgs, inputs, config, ... }: {
        imports = (lib.my.mapModulesRec' ./hm-imports (x: x)) ++ [ "${impermanence}/home-manager.nix" ];
      };

      rev = if (lib.hasAttrByPath [ "rev" ] self.sourceInfo) then self.sourceInfo.rev else "Dirty Build";

      nixosSystem = system: extraModules: hostName:
        let
          pkgs = genPkgs system;
        in
        nixpkgs.lib.nixosSystem
          rec {
            inherit system;
            specialArgs = { inherit lib; };
            modules = [
              agenix.nixosModules.age
              impermanence.nixosModules.impermanence
              home-manager.nixosModules.home-manager
              xynoblog.nixosModule
              x.nixosModule
              ({ config, ... }: lib.mkMerge [{
                _module.args = { inherit inputs; };
                nixpkgs.pkgs = pkgs;
                nixpkgs.overlays = overlays;
                networking.hostName = hostName;
                system.configurationRevision = rev;
                services.getty.greetingLine =
                  "<<< Welcome to ${config.system.nixos.label} @ ${rev} - Please leave \\l >>>";
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.extraSpecialArgs = { inherit inputs; };
              }

                (lib.mkIf config.ragon.user.enable {
                  # import hm stuff if enabled
                  home-manager.users.ragon = hmConfig;
                })])
              ./nixos-common.nix
            ] ++ (lib.my.mapModulesRec' (toString ./nixos-modules) import) ++ extraModules;
          };
      darwinSystem = system: extraModules: hostName:
        let
          pkgs = genPkgsWithOverlays system;
        in
        darwin.lib.darwinSystem
          {
            inherit system;
            specialArgs = { inherit lib pkgs inputs self darwin; };
            modules = [
              home-manager.darwinModules.home-manager
              {
                #system.darwinLabel = "${config.system.darwinLabel}@${rev}";
                networking.hostName = hostName;
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.extraSpecialArgs = { inherit inputs; };
                home-manager.users.ragon = hmConfig;
              }
              ./darwin-common.nix
            ] ++ (lib.my.mapModulesRec' (toString ./darwin-modules) import) ++ extraModules;
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
      nixosModules = lib.my.mapModulesRec ./nixos-modules import;
      darwinModules = [ ];
      #darwinModules = lib.my.mapModulesRec ./darwin-modules import;
      nixosConfigurations = processConfigurations {
        picard = nixosSystem "x86_64-linux" [ ./hosts/picard/default.nix ];
        ds9 = nixosSystem "x86_64-linux" [ ./hosts/ds9/default.nix ];
        daedalusvm = nixosSystem "aarch64-linux" [ ./hosts/daedalusvm/default.nix ];
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
