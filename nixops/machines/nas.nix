{ config, pkgs, lib, ... }:
{
  deployment.targetHost = 192.168.7.96
  networking = {
    domain = "sorsa.cloud";
    hostName = "nixnas";
  }
  imports = [
    ../traits/nfs.nix
  ];
}
