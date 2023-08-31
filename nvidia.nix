{ config, ... }:

{
  services.xserver.videoDrivers = [ "nvidia" ];
  services.xserver.dpi = 96;

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    forceFullCompositionPipeline = true;
  };
}
