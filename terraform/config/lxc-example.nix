{ lib, inputs, pkgs, vm-images, ... }:
let
  vm-config = vm-images.nixosConfigurations.base.lxc-container.${pkgs.system};
  lxc-tarball = "${vm-config.config.system.build.tarball}/tarball/${vm-config.config.system.build.tarball.fileName}.tar.xz";
  lxc-metadata = "${vm-config.config.system.build.metadata}/tarball/${vm-config.config.system.build.metadata.fileName}.tar.xz";
in
{
  terraform.required_providers.lxd = {
    source = "terraform-lxd/lxd";
    version = "1.9.1";
  };

  provider.lxd = { };

  module.shell-lxd-image = {
    source = "Invicton-Labs/shell-resource/external";
    version = "0.4.1";

    command_unix = "lxc image import $LXC_METADATA $LXC_TARBALL --alias nixos | cut -c 35-";
    command_destroy_unix = "lxc image rm nixos";

    fail_create_on_stderr = true;

    environment = {
      LXC_METADATA = lxc-metadata;
      LXC_TARBALL = lxc-tarball;
    };
  };

  resource.lxd_network.raft_network = {
    name = "raft_network";

    config = {
      "ipv4.address" = "192.168.58.1/24";
      "ipv4.nat" = true;
    };
  };

  resource.lxd_profile.raft_profile = {
    name = "raft_profile";

    device = [
    {
      name = "eth0";
      type = "nic";

      properties = {
        nictype = "bridged";
        parent = "\${lxd_network.raft_network.name}";
      };
    }
    
    {
      type = "disk";
      name = "root";

      properties = {
        path = "/";
        pool = "default";
      };
    }
    ];
  };

  resource.lxd_container.nodes = {
    count = 2;
    name = "nixnode-\${count.index}";
    image = "nixos";

    profiles = [
      "\${lxd_profile.raft_profile.name}"
    ];

    depends_on = [ "module.shell-lxd-image" ];
  };

  output.servers.value = "\${[ for server in resource.lxd_container.nodes : { name = server.name, ipv4 = server.ipv4_address, domain = \"sorsa.cloud\", type = \"lxc\" } ]}";
}
