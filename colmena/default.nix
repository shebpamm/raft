{ inputs, servers }:
let
  machines = import ./machines.nix { inherit inputs servers; };

  getServerSpec = name: value:
    let
      specName = builtins.substring 0 (builtins.stringLength name - 2) name;
    in
    { spec = servers.${specName}; };

  serverSpecs = builtins.mapAttrs getServerSpec machines;
in
{
  colmena = {
    meta = {
      name = "Raft";
      description = "Sorsa Network";
      nixpkgs = import inputs.system-nixpkgs {
        system = "x86_64-linux";
        allowUnfree = true;
      };
      nodeSpecialArgs = serverSpecs;
    };
    defaults = import ./common.nix { inherit inputs servers; };
  } // machines;
}
