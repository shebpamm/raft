{ pkgs, inputs }:
let
  system = pkgs.system;
  terraform = pkgs.terraform;
  terraformConfiguration = inputs.terranix.lib.terranixConfiguration {
    inherit system;
    extraArgs = { inherit inputs; };
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
}
