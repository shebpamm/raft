{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    terranix = {
      url = "github:terranix/terranix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs @ { self, nixpkgs, flake-utils, terranix }:
    let
      mergeModules = modules: builtins.foldl' (p: n: p // n) { } (map (m: import m { inherit inputs; }) modules);
        in
        mergeModules [ ./terraform ./nixops ./vm-images ];
      }
