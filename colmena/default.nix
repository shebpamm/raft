{ inputs, servers }:
let
  machines = import ./machines.nix { inherit inputs servers; };

  # Implementation currently assumes max count of 10, yikes
  getServerSpec = name: value:
    let
      specName = builtins.substring 0 (builtins.stringLength name - 2) name;
    in
    servers.${specName};

  getServerIndex = name: value: builtins.substring (builtins.stringLength name - 1) 1 name;

  getNodeSpec = name: value: {
    spec = getServerSpec name value;
    index = getServerIndex name value;
  };

  nodeSpecs = builtins.mapAttrs getNodeSpec machines;
in
{
  inherit nodeSpecs;
  colmena = {
    meta = {
      name = "Raft";
      description = "Sorsa Network";
      nixpkgs = import inputs.system-nixpkgs {
        system = "x86_64-linux";
        allowUnfree = true;
      };
      specialArgs = { inherit machines; };
      nodeSpecialArgs = nodeSpecs;
    };
    defaults = import ./common.nix { inherit inputs servers; };
  } // machines;
}
