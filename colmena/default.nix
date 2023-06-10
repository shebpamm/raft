{ inputs, servers }:
let
  machines = import ./machines.nix { inherit inputs; };
in
{
  colmena = {
    meta = {
      name = "Raft";
      description = "Sorsa Network";
      nixpkgs = import inputs.nixpkgs {
        system = "x86_64-linux";
        allowUnfree = true;
      };
    };
    defaults = import ./common.nix { inherit inputs; };
  } // machines;
}
