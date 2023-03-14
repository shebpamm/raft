{ lib, inputs, pkgs, vm-images, ... }:
let
  vm-config = vm-images.nixosConfigurations.base.esxi.${pkgs.system};
in
rec {
  terraform.required_providers.vsphere = {
    source = "hashicorp/vsphere";
    version = "2.3.1";
  };

  data.vault_kv_secret_v2.vsphere_secrets = {
    mount = "sorsalab";
    name = "vsphere";
  };

  provider.vault = { };

  provider.vsphere = {
    user = "\${data.vault_kv_secret_v2.vsphere_secrets.data.vsphere_username}";
    password = "\${data.vault_kv_secret_v2.vsphere_secrets.data.vsphere_password}";
    vsphere_server = "\${data.vault_kv_secret_v2.vsphere_secrets.data.vsphere_hostname}";
    allow_unverified_ssl = true;
  };

  data.vsphere_datacenter.datacenter = {
    name = "ha-datacenter";
  };

  data.vsphere_datastore.datastore = {
    datacenter_id = "\${data.vsphere_datacenter.datacenter.id}";
    name = "Main Storage";
  };

  data.vsphere_resource_pool.pool = {
    name = "Virtual Machines";
    datacenter_id = "\${data.vsphere_datacenter.datacenter.id}";
  }; 

  resource.vsphere_virtual_machine.esxi-nodes = {
    count = 1;
    name = "esxi-node-\${count.index}";
    num_cpus = 2;
    memory = 4096;
    guest_id = "otherGuest64";
    datastore_id = "\${data.vsphere_datastore.datastore.id}";
    resource_pool_id = "\${data.vsphere_resource_pool.pool.id}";
    network_interface = {
      network_id = "Virtual Machines";
    };
    disk = {
      label = "nix-disk-root";
      size = 20;
    };

  };
}
