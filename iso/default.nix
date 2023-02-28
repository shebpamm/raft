{ nixpkgs, system }:
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
  nixosConfigurations = {
    base = bases;
  };
}
