{ inputs, servers }:
let
  terraform-machines = import ./terraform-machines.nix { inherit inputs; };
  machines = import ./machines;

  diskoConfigs = import ../disko { inherit inputs servers; };

  addTraits = machines: builtins.mapAttrs
    (name: machine:
      let
        specName = builtins.substring 0 (builtins.stringLength name - 2) name;
        server = servers.${specName};
        traits = builtins.map (trait: ./traits/${trait}.nix) server.traits;
        diskoModule = {
          imports = [ inputs.disko.nixosModules.disko ];
          disko = diskoConfigs.diskoConfigurations.${specName}.disko;
        };
      in
      machine // { imports = traits ++ [ diskoModule ]; }
    )
    machines;
in
addTraits (machines // terraform-machines)
