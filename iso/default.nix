{ nixpkgs, system }: {
    nixosConfigurations.base = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        (nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix")
      ];
    };
  };
