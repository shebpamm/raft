{ inputs }:
let
  lib = inputs.nixpkgs.lib;

  server = serv: {
    name = serv.name;

    value = {
      networking = {
        hostName = serv.name;
        domain = serv.domain;
      };
      deployment.targetHost = serv.ip;
    };
  };

  terraform-servers-json = (lib.importJSON ./terraform.json).servers.value;
  terraform-servers = map server terraform-servers-json;
in
builtins.listToAttrs terraform-servers
