# Note: Exclusively works with specific versions of both the unstable
# (19cf008b) and stable channels (b83e7f5) and nixos-generators 
# (30516cb2). Only dog knows why.
# The sole way to test it, is to actually deploy the resulting image
# using ovftool (if you want to use the tool). Deploying it over webui
# is a bit less picky, so you might get away with other commits.
{ inputs }:
let
  pkgs = import inputs.nixpkgs {
    system = "x86_64-linux";
    config = { allowUnfree = true; };
  };

  unfixed = inputs.nixos-generators.nixosGenerate {
    inherit pkgs;
    modules = [
      ./base.nix
      ({ config, pkgs, system, ... }:
      {
        virtualbox = {
          # see: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/virtualisation/virtualbox-image.nix
          memorySize = 4000; # MiB
          params = {
            # audiocontroller = "off";
            audio = "none";
            audioout = "off";
          };
        };
        virtualisation.vmware.guest.enable = true;
      })
    ];
    format = "virtualbox";
  };
  vmx = "vmx-13"; # see: https://kb.vmware.com/s/article/1003746
in
pkgs.runCommand "nixovabase" { } ''
  ova=${unfixed}/*.ova
  mkdir $out
  # cp $ova "$out/unfixed.ova"  # debug
  ${pkgs.cot}/bin/cot --force --verbose edit-product $ova -p 'Some Info' -o nixos.ova
  ${pkgs.cot}/bin/cot --force --verbose edit-hardware nixos.ova -v ${vmx}
  tar xf nixos.ova
  sed -i -E 's/^(\s*<(ovf:)?ProductSection)>\s*$/\1 ovf:required="false">/' *.ovf
  sed -i -E "s/^(SHA1\(nixos.ovf\)=\s*).*$/\1$(sha1sum nixos.ovf | cut -d ' ' -f 1)/" *.mf
  ${pkgs.ovftool}/bin/ovftool --lax --sourceType=OVF --targetType=OVA nixos.ovf $out/nixos.ova
  # tar cf $out/nixos.ova *.ovf *.mf *.vmdk
''
