{ lib, ... }:
{
  terraform.required_providers.virtualbox = {
    source = "terra-farm/virtualbox";
    version = "0.2.2-alpha.1";
  };

  resource.virtualbox_vm.node = {
    name = "virtualbox-node";
    image = "https://app.vagrantup.com/shebpamm123/boxes/nixos/versions/22.05/providers/virtualbox.box";
    cpus = 2;
    memory = "512 mib";

    network_adapter = {
      type = "hostonly";
      host_interface = "vboxnet0";
    };
  };

  output.vbox_test.value = "\${virtualbox_vm.node}";
}
