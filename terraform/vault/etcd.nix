args@{ servers, lib, ... }:
let
  net = import ../../net.nix { inherit lib; }; # Ugly, would be better to add as overlay to nixpkgs-system in flakes
  getIp = { spec, index, ... }: net.lib.net.cidr.host ((lib.strings.toInt index) + 1) spec.network.ipv4pool;
  getHostname = { name, index }: "${name}-${index}";

  resolve = with builtins; args@{ name, spec, index }: l:
    if typeOf l == "function" then
      l args
    else if typeOf l == "list" then
      map
        (e:
          if typeOf e == "lambda" then
            (e args)
          else
            e
              l)
    else
      l;

  pki = import ./pki.nix args;
  backend = pki.resource.vault_mount.pki_etcd.path;
  role = pki.resource.vault_pki_secret_backend_role.sorsalab_etcd_role.name;

  certs = {
    kube_etcd = {
      common_name = "kube-etcd";
      alt_names = [
        getHostname
        "localhost"
      ];
      ip_sans = [
        getIp
        "127.0.0.1"
      ];
    };
  };

  nodes = with builtins; lib.attrsets.filterAttrs (n: v: elem "etcd" v.traits) servers;

in
(with builtins; mapAttrs
  (
    name: spec:
    map
      (
        index:
        mapAttrs
          (
            certName: certSpec:
            let
              resolver = { inherit name spec index; };
              in {
              resource.vault.pki_secret_backend_cert.${certName} = {
                depends_on = [ "vault_pki_secret_backend_intermediate_cert_request.sorsalab-etcd-role" ];
                backend = backend;
                name = role;
                ttl = "8760h";
                common_name = resolver certSpec.common_name;
                alt_names = resolver certSpec.alt_names;
                ip_sans = resolver certSpec.ip_sans; 
              };
            }
          )
          certs
      )
      (lib.lists.range 0 spec.count - 1)
  )
  nodes)

# {
#   resource.vault.pki_secret_backend_cert.kube_etcd = {
#     depends_on = [ "vault_pki_secret_backend_intermediate_cert_request.sorsalab-etcd-role" ];
#     backend = "pki-etcd";
#     name = "kube-etcd";
#   };
# }
