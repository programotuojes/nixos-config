{ pkgs, pkgs-unstable, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./nvidia.nix
    ./syncthing.nix
    ./work.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "LBook";

  networking.networkmanager.enable = true;
  networking.hosts."10.0.0.10" = [
    # TODO remove once a local DNS is set up
    "grafana.severas.lan"
    "tube.severas.lan"
  ];

  time.timeZone = "Europe/Vilnius";
  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.desktopManager.plasma5.enable = true;
  services.xserver.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    autoNumlock = true;
    settings.Autologin.Session = "plasmawayland.desktop";
    settings.Autologin.User = "gustas";
  };

  environment.variables = {
    TIMEFORMAT = "\nElapsed: %1R (%0lR)";
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };

  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.gustas = {
    isNormalUser = true;
    description = "Gustas";
    extraGroups = [ "networkmanager" "wheel" "docker" "adbusers" ];
    packages = with pkgs; [
      anki
      appimage-run
      burpsuite
      deluge
      discord
      gimp
      git-crypt
      jdk
      jellyfin-media-player
      jq
      kate
      libreoffice
      libsForQt5.yakuake
      nerdfonts
      nextcloud-client
      nixpkgs-fmt
      nvd
      openfortivpn
      parallel
      pkgs-unstable.insomnia
      pkgs-unstable.obsidian
      spotify
      sqlitebrowser
      telegram-desktop
      tmux
      vlc
      wl-clipboard
      zoxide

      # Neovim stuff
      cargo
      gcc
      ripgrep
      unzip
    ];
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    lm_sensors
    openssl
    ntfs3g
    file
    wget
  ];

  fonts.packages = with pkgs; [
    jetbrains-mono
    ipafont
  ];

  fonts.fontconfig = {
    allowBitmaps = false;

    antialias = true;
    hinting.enable = true;
    hinting.style = "slight";
    subpixel.rgba = "rgb";

    defaultFonts = {
      monospace = [
        "JetBrains Mono"
        "IPAGothic"
      ];
      sansSerif = [
        "Noto Sans"
        "IPAPGothic"
      ];
      serif = [
        "Noto Serif"
        "IPAPMincho"
      ];
    };
  };

  networking.firewall.enable = true;

  system.stateVersion = "23.11";

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
  };

  security.sudo.wheelNeedsPassword = false;

  hardware.bluetooth.enable = true;

  virtualisation.docker.enable = true;

  services.fstrim.enable = true;

  services.flatpak.enable = true;

  programs.adb.enable = true;

  # https://github.com/NixOS/nixpkgs/issues/207339#issuecomment-1747101887
  programs.dconf.enable = true;
}
