{
  description = "A thing";

  inputs = {
    conf.url = "git+https://gitlab.hochkamp.eu/ragon/nixos";
  };

  outputs = inputs @ { conf, ... }: {
    nixosConfigurations = conf.lib.mapHosts ./hosts {
      imports = [
        # If this is a linode machine
        # "${dotfiles}/hosts/linode.nix"
      ];
    };
  };
}
