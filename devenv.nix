{ pkgs, ... }:

{
  scripts = { };
  packages = with pkgs;
    [
      terraform
    ];
  env = {
    VAULT_ADDR = "https://vault.sorsa.cloud";
  };
}
