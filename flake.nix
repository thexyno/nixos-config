{
  description = "OS level Autism, Goblins";

  inputs = {
    # nix inputs
    nixos.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-master.url = "github:NixOS/nixpkgs";
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixos";
    home-manager.url = "github:nix-community/home-manager";

    rnix-lsp.url = "github:nix-community/rnix-lsp/master";                                                             

    # other inputs

    ## applications
    dwm.url = "git+https://gitlab.hochkamp.eu/ragon/dwm";
    dwm.flake = false;
    nextshot.url = "github:dshoreman/nextshot/develop";                                                                
    nextshot.flake = false;
    pandoc-latex-template.url = "github:Wandmalfarbe/pandoc-latex-template/master";                                    
    pandoc-latex-template.flake = false;
    pandocode.url = "github:nzbr/pandocode/master";                                                                    
    pandocode.flake = false;

    ## vim
    coc-nvim.url = "github:neoclide/coc.nvim/release";                                                                 
    coc-nvim.flake = false;
    nnn-vim.url = "github:mcchrish/nnn.vim/master";                                                                    
    nnn-vim.flake = false;

    ## zsh
    zsh-completions.url = "github:zsh-users/zsh-completions/master";                                                   
    zsh-completions.flake = false;
    zsh-syntax-highlighting.url = "github:zsh-users/zsh-syntax-highlighting/master";                                   
    zsh-syntax-highlighting.flake = false;
    zsh-vim-mode.url = "github:softmoth/zsh-vim-mode/master";
    zsh-vim-mode.flake = false;
    agkozak-zsh-prompt.url = "github:agkozak/agkozak-zsh-prompt/master";                                               
    agkozak-zsh-prompt.flake = false;


  };


  outputs = inputs @ { self, nixos, nixos-master, ... }: 
    let
      inherit (lib.my) mapModules mapModulesRec mapHosts;
      system = "x86_64-linux"; # when rpis get into play, that needs changes
      mkPkgs = pkgs: extraOverlays: import pkgs { # apply config and overlays to following pkgs
        inherit system;
        config.allowUnfree = true; # fuck rms and his cult
        overlays = extraOverlays ++ (lib.attrValues self.overlays);
      };
      pkgs = mkPkgs nixos [ self.overlay ];
      pkgs' = mkPkgs nixos-master [];

      lib = nixpkgs.lib.extend # extend lib with the stuff in ./lib
          (self: super: { my = import ./lib { inherit pkgs inputs; lib = self; }; });

    in
    {
      lib = lib.my; # idk

      # TODO figure agenix out
      secrets = import ./data/load-secrets.nix;
      pubkeys = import ./data/pubkeys.nix;

      overlay =
        final: prev: {
          master = pkgs';
          my = self.packages."${system}"; # idk
        };
      overlays =
        mapModules ./overlays import; # placeholder for when I add my own overlays

      packages."${system}" =
        mapModules ./packages (p: pkgs.callPackage p {}); # load my own packages (pandocode)

      nixosModules =
        { dotfiles = import ./.; } // mapModulesRec ./modules import; # load all the juicy modules

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
