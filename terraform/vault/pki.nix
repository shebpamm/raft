{ ... }:
rec {
  terraform.required_providers = {
    vault =
      {
        source = "hashicorp/vault";
        version = "3.23.0";
      };
  };

  provider.vault = {
    address = "https://vault.sorsa.cloud";
  };

  resource.vault_mount.pki = {
    path = "pki";
    type = "pki";
    default_lease_ttl_seconds = 315360000; # 10 years
    max_lease_ttl_seconds = 315360000; # 10 years
  };

  resource.vault_pki_secret_backend_root_cert.sorsalab-root = {
    backend = resource.vault_mount.pki.path;
    type = "internal";
    common_name = "sorsa.cloud";
    ttl = "315360000"; # 10 years
    format = "pem";
    key_type = "rsa";
    key_bits = 4096;
    organization = "Sorsalab";
  };

  resource.vault_pki_secret_backend_role.sorsalab-role = {
    backend = resource.vault_mount.pki.path;
    name = "sorsalab-role";
    allowed_domains = [ "sorsa.cloud" ];
    allow_subdomains = true;
    allow_glob_domains = true;
    allow_any_name = true;
  };

  resource.vault_pki_secret_backend_config_urls.sorsalab-urls = {
    backend = resource.vault_mount.pki.path;
    crl_distribution_points = [
      "https://vault.sorsa.cloud/v1/pki/crl"
    ];
    issuing_certificates = [
      "https://vault.sorsa.cloud/v1/pki/ca"
    ];
  };

  resource.vault_mount.pki_etcd = {
    path = "pki-etcd";
    type = "pki";
    default_lease_ttl_seconds = 315360000; # 10 years
    max_lease_ttl_seconds = 315360000; # 10 years
  };

  resource.vault_pki_secret_backend_intermediate_cert_request.sorsalab-etcd-request = {
    backend = resource.vault_mount.pki_etcd.path;
    type = "internal";
    common_name = "kube etcd Intermediate Authority";
    key_type = "rsa";
    key_bits = 4096;
  };

  resource.vault_pki_secret_backend_root_sign_intermediate.sorsalab-etcd-signed = {
    depends_on = [ "vault_pki_secret_backend_intermediate_cert_request.sorsalab-etcd-request" ];
    backend = resource.vault_mount.pki.path;
    csr = "\${vault_pki_secret_backend_intermediate_cert_request.sorsalab-etcd-request.csr}";
    common_name = "kube etcd Intermediate Authority";
    ttl = "315360000"; # 10 years
  };

  resource.vault_pki_secret_backend_intermediate_set_signed.sorsalab-etcd-set-signed = {
    backend = resource.vault_mount.pki_etcd.path;
    certificate = "\${vault_pki_secret_backend_root_sign_intermediate.sorsalab-etcd-signed.certificate}";
  };

  resource.vault_pki_secret_backend_role.sorsalab-etcd-role = {
    backend = resource.vault_mount.pki_etcd.path;
    name = "kube-etcd";
    allow_any_name = true;
    max_ttl = "315360000"; # 10 years
  };

  output.root_ca = {
    value = "\${vault_pki_secret_backend_root_cert.sorsalab-root.certificate}";
  };

}
