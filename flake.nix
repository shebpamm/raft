{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    vm-images =
      {
        url = "path:./vm-images";
        inputs.nixpkgs.follows = "nixpkgs";
      };
    terranix = {
      url = "github:terranix/terranix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { self, nixpkgs, flake-utils, terranix, vm-images }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs { inherit system; };

          terraform = import ./terraform { inherit pkgs inputs; };
        in
        terraform
      ) // vm-images.outputs // import ./nixops { inherit inputs;};
}
