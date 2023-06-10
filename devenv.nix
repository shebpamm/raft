{ pkgs, ... }:

{
  scripts = { };
  packages = with pkgs;
    [
      terraform
      colmena
    ];
  env = {
    VAULT_ADDR = "https://vault.sorsa.cloud";
  };
}
