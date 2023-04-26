{ pkgs, ... }:

{
  scripts = { };
  packages = with pkgs;
    [
      terraform
      nixops_unstable
    ];
  env = {
    VAULT_ADDR = "https://vault.sorsa.cloud";
  };
}
