{ inputs, servers }:

inputs.flake-utils.lib.eachDefaultSystem (system:
let
  pkgs = import inputs.nixpkgs {
    system = "x86_64-linux";
    config = { allowUnfree = true; };
  };
  vm-images = import ../vm-images { inherit inputs; };
  terraform = pkgs.terraform;

  terraformConfiguration = inputs.terranix.lib.terranixConfiguration {
    inherit system;
    extraArgs = {
      inherit inputs vm-images servers;
    };
    modules = [
      ./backends/esxi.nix
      ./vault
    ];
  };
in
{
  inherit terraformConfiguration;
  # nix run ".#apply"
  apps.apply = {
    type = "app";
    program = toString (pkgs.writers.writeBash "apply" ''
      if [[ -e config.tf.json ]]; then rm -f config.tf.json; fi
      cp ${terraformConfiguration} config.tf.json \
        && ${terraform}/bin/terraform init \
        && ${terraform}/bin/terraform apply \
        && ${terraform}/bin/terraform output -json > colmena/terraform.json
    '');
  };
  # nix run ".#destroy"
  apps.destroy = {
    type = "app";
    program = toString (pkgs.writers.writeBash "destroy" ''
      if [[ -e config.tf.json ]]; then rm -f config.tf.json; fi
      cp ${terraformConfiguration} config.tf.json \
        && ${terraform}/bin/terraform init \
        && ${terraform}/bin/terraform destroy
    '');
  };
})
