{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    iso-images =
      {
        url = "path:./iso";
        inputs.nixpkgs.follows = "nixpkgs";
      };
    terranix = {
      url = "github:terranix/terranix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { self, nixpkgs, flake-utils, terranix, iso-images }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        terraform = import ./terraform { inherit pkgs inputs; };
      in
      terraform
    ) // iso-images.outputs;
}
