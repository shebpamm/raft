{
  description = "Machine builder";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        createVM = type: {
          "${type}" = nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [
              (nixpkgs + "/nixos/modules/virtualisation/${type}-image.nix")
              ./base.nix
            ];
          };
        };
        bases = builtins.foldl'
          (acc: type:
            createVM type
            // acc)
          { } [ "virtualbox" "vmware" ];
      in
      {
        nixosConfigurations."base" = bases;
      });
}
