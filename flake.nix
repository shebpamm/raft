{
  inputs = {
    system-nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    disko.url = "github:nix-community/disko";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    terranix = {
      url = "github:terranix/terranix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs @ { self, system-nixpkgs, nixpkgs, flake-utils, nixos-generators, terranix, disko }:
    let
      pkgs = (import nixpkgs { system = "x86_64-linux"; });
      servers = import ./servers.nix;
      mergeModules = modules: builtins.foldl' (p: n: pkgs.lib.attrsets.recursiveUpdate p n) { } (map (m: import m { inherit inputs servers; }) modules);
    in
    mergeModules [ ./terraform ./colmena ./vm-images ./disko ];
}
