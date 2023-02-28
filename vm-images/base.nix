{ config, pkgs, system, ... }:
{
  system.stateVersion = "22.05";
  boot.initrd.checkJournalingFS = false;
  services.openssh =
    {
      enable = true;
      settings.permitRootLogin = "yes";
      extraConfig = ''
        PubkeyAcceptedKeyTypes +ssh-rsa
      '';
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
