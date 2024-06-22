{ ... }:

{
  boot.kernelParams = [
    "nvidia_drm.fbdev=1"
  ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
  };
}
