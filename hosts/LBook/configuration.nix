{ pkgs, inputs, specialArgs, ... }:

{
  imports = [
    ../../users/gustas.nix
    ./hardware-configuration.nix
    ./home.nix
    ./hyprland.nix
    ./work.nix
    inputs.home-manager.nixosModules.default
  ];

  networking.hostName = "LBook";

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = specialArgs;
  };

  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nix.optimise.automatic = true;
  nix.optimise.dates = [ "Mon 04:00" ];

  nix.gc.automatic = true;
  nix.gc.dates = "Tue 04:00";
  nix.gc.options = "--delete-older-than 30d";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;
  networking.hosts."10.0.0.2" = [
    # TODO remove once a local DNS is set up
    "grafana.severas.lan"
    "tube.severas.lan"
  ];

  time.timeZone = "Europe/Vilnius";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [
      "C.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
      "lt_LT.UTF-8/UTF-8"
    ];
  };

  environment.variables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    lm_sensors
    openssl
    ntfs3g
  ];

  system.stateVersion = "23.11";

  networking.firewall.enable = true;
  security.sudo.wheelNeedsPassword = false;
  hardware.bluetooth.enable = true;
  virtualisation.docker.enable = true;
  services.fstrim.enable = true;
  services.flatpak.enable = true;
  programs.adb.enable = true;

  # https://github.com/NixOS/nixpkgs/issues/207339#issuecomment-1747101887
  programs.dconf.enable = true;

  fonts = {
    packages = with pkgs; [
      jetbrains-mono
      dejavu_fonts
      noto-fonts
      # (nerdfonts.override { fonts = [ "JetBrainsMono" "Noto" ]; })
      ipafont
    ];

    fontconfig = {
      allowBitmaps = false;

      antialias = true;
      hinting.enable = true;
      hinting.style = "slight";
      subpixel.rgba = "rgb";

      defaultFonts = {
        monospace = [
          "JetBrains Mono"
          # "JetBrainsMono Nerd Font"
          "IPAGothic"
        ];
        sansSerif = [
          "Noto Sans"
          # "NotoSans Nerd Font"
          "IPAPGothic"
        ];
        serif = [
          "Noto Serif"
          # "NotoSerif Nerd Font"
          "IPAPMincho"
        ];
      };
    };
  };

  users.users.gustas.extraGroups = [ "networkmanager" "adbusers" "input" ];

  boot.kernelParams = [
    "nvidia_drm.fbdev=1"
  ];

  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
    powerManagement.enable = true;
  };
}
