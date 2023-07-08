{
  coalesce = {
    count = 1;
    type = "esxi";
    network = {
      ipv4pool = "192.168.7.50/28";
    };
    traits = [
      "esxi"
      "fish"
      "static"
      "consul"
    ];
    specs = {
      cpus = 1;
      memory = 1024;
      disk = 10; # Gigabytes, this is the data disk. The OS disk is 32GB.
    };
  };
  testing = {
    count = 1;
    type = "esxi";
    network = {
      ipv4pool = "192.168.7.30/32";
    };
    traits = [
      "esxi"
      "fish"
      "static"
    ];
    specs = {
      cpus = 1;
      memory = 1024;
      disk = 10; # Gigabytes, this is the data disk. The OS disk is 32GB.
    };
  };
}
