{ inputs, servers }:
let
  terraform-machines = import ./terraform-machines.nix { inherit inputs; };
  machines = import ./machines;

  addTraits = machines: builtins.mapAttrs (name: machine:
    let
      specName = builtins.substring 0 (builtins.stringLength name - 2) name;
      server = servers.${specName};
      traits = builtins.map (trait: ./traits/${trait}.nix) server.traits;
    in
    machine // { imports = traits; }
  ) machines;
in
addTraits (machines // terraform-machines)
