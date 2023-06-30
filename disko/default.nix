{ servers, ... }:
{
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
