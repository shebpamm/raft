{ name, nodes, ... }:
{
  services.kubernetes = {
    apiserver = {
      enable = false;
      
    };
  };
}
