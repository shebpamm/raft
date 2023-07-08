{ name, nodes, ... }:
{
  services.consul = {
    enable = true;

    dropPrivileges = true;
    webUi = true;

    extraConfig = {
      bind_addr = "0.0.0.0";
      advertise_addr = nodes.${name}.config.deployment.targetHost;
      server = true;
    };
  };

  # https://developer.hashicorp.com/consul/docs/install/ports
  networking.firewall.allowedTCPPorts = [
    8500
    8600
    8301
    8302
    8300
  ];
}
