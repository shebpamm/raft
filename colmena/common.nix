{ inputs, servers }: { config, pkgs, lib, ... }:
{
  documentation.nixos.enable = false;

  system.stateVersion = "22.05";
  boot.initrd.checkJournalingFS = false;
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "prohibit-password";
    extraConfig = ''
      PubkeyAcceptedKeyTypes +ssh-rsa
    '';
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
    autoResize = true;
  };
  boot = {
    growPartition = true;
    loader.grub.device = "/dev/sdb"; # TODO: Find a better solution, seems like it's always sdb for now
    loader.timeout = 0;
  };

  environment.systemPackages = with pkgs;
    [
      htop
      mtr
      tmux
    ];

  programs.zsh.enable = true;
  services.logrotate.enable = true;

  # Nix
  nix = {
    # Only use Flakes
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    registry.nixpkgs.flake = inputs.system-nixpkgs;
    nixPath = [ ];
    # Garbage collection
    gc = {
      automatic = true;
      dates = "03:15";
      options = "--delete-older-than 8d";
    };
  };

  # Firewall
  networking.firewall = {
    enable = true;
    rejectPackets = true;
    allowPing = true;
    allowedTCPPorts = [ 22 ];
  };

  users = {
    mutableUsers = false;
    users = {
      root = {
        openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK2zXSYBvkCarq9hsQmYAilLbrCaFqDaW7eV8S1nK+oC shebpamm@sorsa.cloud" ];
      };
    };
  };
}
