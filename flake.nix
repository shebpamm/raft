{
  inputs = {
    system-nixpkgs.url = "github:nixos/nixpkgs";
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
  outputs = inputs @ { self, system-nixpkgs, nixpkgs, flake-utils, nixos-generators, terranix }:
    let
      servers = import ./servers.nix;
      mergeModules = modules: builtins.foldl' (p: n: p // n) { } (map (m: import m { inherit inputs servers; }) modules);
    in
    mergeModules [ ./terraform ./colmena ./vm-images ];
}
