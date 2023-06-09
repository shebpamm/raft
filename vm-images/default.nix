{ inputs }:
let
  bases = inputs.flake-utils.lib.eachDefaultSystem (system:
    let
      customGenerators = names:
        builtins.map
          (name: {
            inherit name;
            module = ./generators/${name}.nix;
          })
          names;
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
    in
    builtins.foldl'
      (acc: type:
        createVM type
        // acc)
      { }
      ((defaultGenerators [ "virtualbox-image" "vmware-image" "lxc-container" ])));
  esxi = import ./esxi.nix { inherit inputs; };

in
{
  nixosConfigurations."base" = bases;
  nixosImages.esxi = esxi;
}
