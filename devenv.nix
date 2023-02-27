{ pkgs, ... }:

{
  scripts = { };
  packages = with pkgs;
    [
      terraform
    ];
}
