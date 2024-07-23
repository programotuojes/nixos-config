{ config, ... }:

{
  networking = {
    hostName = "severas";
    hostId = "9c295bfe";
    useDHCP = false;
  };

  systemd.network.enable = true;
  systemd.network.networks."10-1gbps-lan" = {
    matchConfig.Name = "enp0s31f6";
    networkConfig = {
      Address = "10.0.0.2/24";
      Gateway = "10.0.0.1";
      DNS = "10.0.0.1";
    };
  };
}
