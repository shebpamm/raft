{ spec, index, lib, ... }:
let
  net = import ../../net.nix { inherit lib; }; # Ugly, would be better to add as overlay to nixpkgs-system in flakes
  ipAddress = net.lib.net.cidr.host ((lib.strings.toInt index) + 1) spec.network.ipv4pool;
in
{
  networking.useDHCP = true;
  systemd.network.enable = true;
  systemd.network.networks = {
    "10-lan" = rec {
      matchConfig.Name = "en*";
      address = [
        ipAddress
      ];
      gateway = [ "192.168.7.1" ];
      dns = gateway;
    };
  };
}
