{ spec, ... }:
{
  networking.useDHCP = true;
  systemd.network.enable = true;
  systemd.network.networks = {
    "10-lan" = rec {
      matchConfig.Name = "en*";
      address = [
        spec.network.ipv4address
      ];
      gateway = [ "192.168.7.1" ];
      dns = gateway;
    };
  };
}
