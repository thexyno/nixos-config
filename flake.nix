{
  description = "OS level Autism, Goblins";

  inputs = {
    # nix inputs
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs";
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    impermanence.url = "github:nix-community/impermanence";
    impermanence.inputs.nixpkgs.follows = "nixpkgs";

    #rnix-lsp.url = "github:nix-community/rnix-lsp";
    #rnix-lsp.inputs.nixpkgs.follows = "nixpkgs";

    # other inputs

    ## applications
    dwm.url = "git+https://gitlab.hochkamp.eu/ragon/dwm";
    dwm.flake = false;
    nextshot.url = "github:dshoreman/nextshot/develop";                                                                
    nextshot.flake = false;
    pandoc-latex-template.url = "github:Wandmalfarbe/pandoc-latex-template";                                    
    pandoc-latex-template.flake = false;
    pandocode.url = "github:nzbr/pandocode";                                                                    
    pandocode.flake = false;

    ## vim
    coc-nvim.url = "github:neoclide/coc.nvim/release";                                                                 
    coc-nvim.flake = false;
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


  };


  outputs = inputs @ { self, nixpkgs, nixpkgs-master, ... }: 
    let
      inherit (lib.my) mapModules mapModulesRec mapHosts;
      system = "x86_64-linux"; # when rpis get into play, that needs changes
      mkPkgs = pkgs: extraOverlays: import pkgs { # apply config and overlays to following pkgs
        inherit system;
        config.allowUnfree = true; # fuck rms and his cult
        overlays = extraOverlays ++ (lib.attrValues self.overlays);
      };
      pkgs = mkPkgs nixpkgs [ self.overlay ];
      pkgs' = mkPkgs nixpkgs-master [];

      lib = nixpkgs.lib.extend # extend lib with the stuff in ./lib
          (self: super: { my = import ./lib { inherit pkgs inputs; lib = self; }; });

    in
    {
      lib = lib.my; # idk


      overlay =
        final: prev: {
          # TODO figure agenix out
          secrets = import ./data/load-secrets.nix;
          pubkeys = import ./data/pubkeys.nix;
          master = pkgs';
          my = self.packages."${system}"; # idk
        };
      overlays =
        mapModules ./overlays import; # placeholder for when I add my own overlays

      packages."${system}" =
        mapModules ./packages (p: pkgs.callPackage p {}); # load my own packages (pandocode)

      nixosModules =
        { conf = import ./.; } // mapModulesRec ./modules import; # load all the juicy modules

      nixosConfigurations =
        mapHosts ./hosts {};

      devShell."${system}" =
        import ./shell.nix { inherit pkgs; };

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
