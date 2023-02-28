{ inputs }:
let
  lib = inputs.nixpkgs.lib;

  shortName = name: builtins.elemAt (lib.splitString "." name) 0;
  domainName = name: lib.concatStringsSep "." (builtins.tail (lib.splitString "." name));

  server = name: network: imports: extras: extras // {
    networking = (if extras ? "networking" then extras.networking else { }) // {
      hostName = shortName name;
      domain = domainName name;
    };
    deployment.targetHost = network.ipv4_address;
    inherit imports;
  };
  terraform-servers-json = (lib.importJSON ./terraform.json).servers.value;
  terraform-servers = map
    (serv:
      {
        name = shortName serv.name;
        value = server serv.name (builtins.head serv.network_adapter) [ ] { };
      })
    terraform-servers-json;
in
builtins.listToAttrs terraform-servers
