{
  testing = {
    count = 1;
    traits = [
      "fish"
    ];
    type = "esxi";
    specs = {
      cpus = 1;
      memory = 1024;
      disk = 10; # Gigabytes, this is the data disk. The OS disk is 32GB.
    };
  };
}
