{ lib, inputs, pkgs, vm-images, ... }:
let
  ova-drv = vm-images.nixosImages.esxi;
in
rec {
  terraform.required_providers.vsphere = {
    source = "local/hashicorp/vsphere";
    version = "2.13.0";
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

  data.vsphere_network.network = {
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
    datacenter_id = "\${data.vsphere_datacenter.datacenter.id}";
    host_system_id = "ha-host";
    network_interface = {
      network_id = "\${data.vsphere_network.network.id}";
    };
    disk = {
      label = "nix-disk-root";
      size = 20;
    };
    ovf_deploy = {
      allow_unverified_ssl_cert = true;
      local_ovf_path = "${ova-drv}/nixos.ova";
      disk_provisioning = "thin";
    };
    lifecycle = {
      ignore_changes = [ "disk[0].io_share_count" ];
    };
  };

  output.servers.value = "\${[ for server in resource.vsphere_virtual_machine.esxi-nodes : { name = server.name, ipv4 = server.default_ip_address, domain = \"sorsa.cloud\", type = \"esxi\" } ]}";
}
