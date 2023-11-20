{
  coalesce = {
    count = 1;
    type = "esxi";
    network = {
      ipv4pool = "192.168.7.48/28";
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
  kubernetes = {
    count = 3;
    type = "esxi";
    network = {
      ipv4pool = "192.168.7.64/28";
    };
    traits = [
      "esxi"
      "fish"
      "static"
      "kubernetes"
    ];
    specs = {
      cpus = 4;
      memory = 4096;
      disk = 10; # Gigabytes, this is the data disk. The OS disk is 32GB.
    };
  };
  testing = {
    count = 1;
    type = "esxi";
    network = {
      ipv4pool = "192.168.7.32/32";
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
