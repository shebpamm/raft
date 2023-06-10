{ inputs, ... }:
let
  system = "x86_64-linux";
  defaultGenerators = names:
    builtins.map
      (name: {
        inherit name;
        module = inputs.nixpkgs + "/nixos/modules/virtualisation/${name}.nix";
      })
      names;

  createVM = generator: {
    "${generator.name}" = inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        generator.module
        ./base.nix
      ];
    };
  };

  bases = builtins.foldl'
    (acc: type:
      createVM type
      // acc)
    { }
    ((defaultGenerators [ "virtualbox-image" "vmware-image" "lxc-container" ]));
  esxi = import ./esxi.nix { inherit inputs; };

in
{
  nixosImages = { esxi = esxi; } // bases;
}
