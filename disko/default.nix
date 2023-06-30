{ inputs, servers, ... }:
let
  pkgs = import inputs.nixpkgs {
    system = "x86_64-linux";
    config = { allowUnfree = true; };
  };
in
{
  apps.x86_64-linux.disks = {
    type = "app";
    program = toString (pkgs.writers.writeBash "disks" ''
      # Function to display confirmation dialog
      confirm() {
          read -p "$1 [y/N]: " response
          case "$response" in
              [yY][eE][sS]|[yY])
                  true
                  ;;
              *)
                  false
                  ;;
          esac
      }

      if confirm "Watch out! This command will wipe the data disk on host $1! Are you sure?"; then
        # Add your command to wipe the data disk here
        TARGET=$1
        TARGET_USER=$(${pkgs.colmena}/bin/colmena eval -E "{ nodes, ... }: nodes.$TARGET.config.deployment.targetUser" | ${pkgs.jq}/bin/jq -r)
        TARGET_HOST=$(${pkgs.colmena}/bin/colmena eval -E "{ nodes, ... }: nodes.$TARGET.config.deployment.targetHost" | ${pkgs.jq}/bin/jq -r)
        FORMAT_SCRIPT_DRV_PATH=$(${pkgs.colmena}/bin/colmena eval --instantiate -E "{ nodes, ... }: nodes.$TARGET.config.system.build.diskoScript")
        FORMAT_SCRIPT_PATH=$(nix-build --no-out-link $FORMAT_SCRIPT_DRV_PATH)

        nix-copy-closure --to "$TARGET_USER@$TARGET_HOST" $FORMAT_SCRIPT_PATH
        ${pkgs.colmena}/bin/colmena exec --on "$TARGET" "$FORMAT_SCRIPT_PATH"
      else
          echo "User cancelled. Aborting the command."
      fi
    '');
  };

  diskoConfigurations = builtins.mapAttrs
    (n: s: {
      disko.devices.disk.data = {
        device = "/dev/sda";
        type = "disk";
        content = {
          type = "table";
          format = "gpt";
          partitions = [
            {
              name = "data";
              start = "0%";
              end = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/data";
              };
            }
          ];
        };
      };
    })
    servers;
}
