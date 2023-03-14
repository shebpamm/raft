{ inputs }:

inputs.flake-utils.lib.eachDefaultSystem (system:
let
  pkgs = import inputs.nixpkgs { inherit system; };
  vm-images = import ../vm-images { inherit inputs; };
  terraform = pkgs.terraform;
  terraformConfiguration = inputs.terranix.lib.terranixConfiguration {
    inherit system;
    extraArgs = {
      inherit inputs;
      inherit vm-images;
    };
    modules = [ ./config ];
  };
in
{
  # nix run ".#apply"
  apps.apply = {
    type = "app";
    program = toString (pkgs.writers.writeBash "apply" ''
      if [[ -e config.tf.json ]]; then rm -f config.tf.json; fi
      cp ${terraformConfiguration} config.tf.json \
        && ${terraform}/bin/terraform init \
        && ${terraform}/bin/terraform apply
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
