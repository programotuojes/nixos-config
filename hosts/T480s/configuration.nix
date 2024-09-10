{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  system.stateVersion = "24.05";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nix.optimise.automatic = true;
  nix.optimise.dates = [ "Mon 04:00" ];

  nix.gc.automatic = true;
  nix.gc.dates = "Tue 04:00";
  nix.gc.options = "--delete-older-than 7d";

  nixpkgs.config.allowUnfree = true;

  boot.loader.timeout = 0;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "T480s";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Vilnius";
  i18n.defaultLocale = "lt_LT.UTF-8";
  i18n.extraLocaleSettings.LC_ALL = "lt_LT.UTF-8";

  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  users.users.jolanta = {
    isNormalUser = true;
    description = "Jolanta";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  environment.systemPackages = with pkgs; [
    file
    lm_sensors
    ntfs3g
  ];

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  services.printing.enable = true;
  services.fstrim.enable = true;

  hardware.enableRedistributableFirmware = true;
  hardware.bluetooth.enable = true;

  security.sudo.wheelNeedsPassword = false;
}
