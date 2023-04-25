{ inputs }:
let
  terraform-machines = import ./terraform-machines.nix { inherit inputs; };
  machines = import ./machines;
in
machines // terraform-machines
