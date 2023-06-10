{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    terranix = {
      url = "github:terranix/terranix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs @ { self, nixpkgs, flake-utils, nixos-generators, terranix }:
    let
      mergeModules = modules: builtins.foldl' (p: n: p // n) { } (map (m: import m { inherit inputs; }) modules);
        in
        mergeModules [ ./terraform ./colmena ./vm-images ];
      }
