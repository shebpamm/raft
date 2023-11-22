# nix flake example

This example shows how you could use terranix as flake.

* edit `servers.nix`
* `nix run ".#apply"` run `terraform apply`
* `nix run ".#disks <host>` format disks 
* `colmena apply` to apply nixos config
* `nix run ".#destroy"` run `terraform destroy`
