{ ... }:

{
  networking.firewall.allowedTCPPorts = [ 8384 22000 ];
  networking.firewall.allowedUDPPorts = [ 22000 21027 ];

  services.syncthing = {
    enable = true;
    user = "gustas";
    configDir = "/home/gustas/.config/syncthing";
    dataDir = "/home/gustas/Syncthing";
  };
}
