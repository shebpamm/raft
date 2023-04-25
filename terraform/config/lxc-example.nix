{ lib, inputs, pkgs, vm-images, ... }:
let
  vm-config = vm-images.nixosConfigurations.base.lxc-container.${pkgs.system};
  lxc-tarball = "${vm-config.config.system.build.tarball}/tarball/${vm-config.config.system.build.tarball.fileName}.tar.xz";
in
{
  terraform.required_providers.lxd = {
    source = "terraform-lxd/lxd";
    version = "1.9.1";
  };

  provider.lxd = { };

  resource.null_resource.lxd_image = {
    triggers = {
      lxc-tarball = lxc-tarball;
    };
    provisioner.local-exec.command = ''
      lxc image import ${lxc-tarball} --alias nixos
    '';
  };

  resource.lxd_container.nodes = {
    count = 2;
    name = "nixnode-\${count.index}.sorsa.cloud";
    image = "nixos";

    depends_on = [ "null_resource.lxd_image" ];
  };

  output.servers.value = "\${lxd_container.nodes}";
}
