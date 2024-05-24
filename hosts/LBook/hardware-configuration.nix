{ lib, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" "coretemp" ];
  boot.extraModulePackages = [ ];

  boot.initrd.luks.devices."root".device = "/dev/disk/by-uuid/1af79df9-93fc-4f72-ac07-bd5a756334f9";

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/cb55ed52-d282-44bf-9cf8-d7191c7c7b7e";
    fsType = "ext4";
    options = [
      "defaults"
      "noatime"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/0914-0B9E";
    fsType = "vfat";
    options = [
      "defaults"
      "noatime"
    ];
  };

  swapDevices = [
    {
      device = "/.swapfile";
      priority = 100;
      size = 1024 * 32;
    }
    {
      device = "/.swapfile.suspend";
      priority = 0;
      size = 1024 * 32;
    }
  ];

  boot.resumeDevice = "/dev/mapper/root";
  boot.kernelParams = [ "resume_offset=2009088" ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp0s31f6.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp61s0u1u3u3.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp0s20f3.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = true;
}
