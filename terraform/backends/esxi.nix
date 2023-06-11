{ lib, inputs, pkgs, vm-images, servers, ... }:
let
  ova-drv = vm-images.nixosImages.esxi;
  esxi-servers = lib.attrsets.filterAttrs (n: s: s.type == "esxi") servers;

  nodes = builtins.mapAttrs
    (n: s: {
      count = s.count;
      name = "${s.name}-\${count.index}";
      num_cpus = s.specs.cpus;
      memory = s.specs.memory;
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
        size = s.specs.disk;
      };
      ovf_deploy = {
        allow_unverified_ssl_cert = true;
        local_ovf_path = "${ova-drv}/nixos.ova";
        disk_provisioning = "thin";
      };
      lifecycle = {
        ignore_changes = [ "disk[0].io_share_count" ];
      };
    })
    esxi-servers;

  nodeConcat = "concat(" + (
    builtins.concatStringsSep
      ", "
      (builtins.map
        (v: "resource.vsphere_virtual_machine." + v)
        (builtins.attrNames nodes))
  ) + ")";
  output = "\${[ for server in ${nodeConcat} : { name = server.name, ipv4 = server.default_ip_address, domain = \"sorsa.cloud\", type = \"esxi\" } ]}";
in
{
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

  resource.vsphere_virtual_machine = nodes;

  output.servers.value = output;
}
