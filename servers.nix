{
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
      cpus = 8;
      memory = 4096;
      disk = 10; # Gigabytes, this is the data disk. The OS disk is 32GB.
    };
  };
}
