{ ... }:

{
  services.xserver.dpi = 96;

  # Fix glitches after resuming from sleep
  boot.kernelParams = [
    # https://github.com/hyprwm/Hyprland/issues/2950#issuecomment-1684074408
    # "NVreg_RegistryDwords=\"OverrideMaxPerf=0x1\""

    # https://bugs.kde.org/show_bug.cgi?id=448866
    # "NVreg_PreserveVideoMemoryAllocations=1"
    # "NVreg_TemporaryFilePath=/var/tmp"
  ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true; # Can't wake up in Wayland when true https://github.com/NixOS/nixpkgs/issues/254614
    # package = config.boot.kernelPackages.nvidiaPackages.production;
  };
}
