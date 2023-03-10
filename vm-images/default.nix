{ inputs }:
let
  bases = inputs.flake-utils.lib.eachDefaultSystem (system:
    let
      createVM = type: {
        "${type}" = inputs.nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            (inputs.nixpkgs + "/nixos/modules/virtualisation/${type}-image.nix")
            ./base.nix
          ];
        };
      };
    in
    builtins.foldl'
      (acc: type:
        createVM type
        // acc)
      { } [ "virtualbox" "vmware" ]);
in
{
  nixosConfigurations."base" = bases;
}
