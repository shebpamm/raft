{ inputs }:
let
  machines = import ./machines.nix { inherit inputs; };
in
{
  nixopsConfigurations.default = {
    nixpkgs = inputs.nixpkgs;
    network.description = "Sorsa Network";
    network.enableRollback = true;
    network.storage.legacy = { };
    defaults = import ./common.nix { inherit inputs; };
  } // machines;
}
