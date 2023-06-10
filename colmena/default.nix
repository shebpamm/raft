{ inputs }:
let
  machines = import ./machines.nix { inherit inputs; };
in
{
  colmena.default = {
    meta = {
      nixpkgs = import inputs.nixpkgs {
        system = "x86_64-linux";
        allowUnfree = true;
      };
    };
    network.description = "Sorsa Network";
    network.enableRollback = true;
    network.storage.legacy = { };
    defaults = import ./common.nix { inherit inputs; };
  } // machines;
}
