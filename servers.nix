{
  testing = {
    count = 1;
    type = "esxi";
    network.ipv4address = "192.168.7.30/24";
    traits = [
      "fish"
    ];
    specs = {
      cpus = 1;
      memory = 1024;
      disk = 10; # Gigabytes, this is the data disk. The OS disk is 32GB.
    };
  };
}
