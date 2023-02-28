{ lib, inputs, pkgs, ... }:
let
  vm-config = inputs.vm-images.outputs.nixosConfigurations.${pkgs.system}.base;
  ova-drv = vm-config.virtualbox.config.system.build.virtualBoxOVA;
  ova-filename = vm-config.virtualbox.config.virtualbox.vmFileName;
in
{
  terraform.required_providers.virtualbox = {
    source = "terra-farm/virtualbox";
    version = "0.2.2-alpha.1";
  };

  resource.virtualbox_vm.nodes = {
    count = 2;
    name = "nixnode-\${count.index}.sorsa.cloud";
    image = "${ova-drv}/${ova-filename}";
    cpus = 2;
    memory = "512 mib";

    network_adapter = {
      type = "hostonly";
      host_interface = "vboxnet0";
    };
  };

  output.servers.value = "\${virtualbox_vm.nodes}";
}
