{ pkgs, pkgs-unstable, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./hyprland.nix
    ./nvidia.nix
    ./syncthing.nix
    ./work.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nix.optimise.automatic = true;
  nix.optimise.dates = [ "Mon 04:00" ];

  nix.gc.automatic = true;
  nix.gc.dates = "Tue 04:00";
  nix.gc.options = "--delete-older-than 30d";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "LBook";

  networking.networkmanager.enable = true;
  networking.hosts."10.0.0.2" = [
    # TODO remove once a local DNS is set up
    "grafana.severas.lan"
    "tube.severas.lan"
  ];

  time.timeZone = "Europe/Vilnius";
  i18n.defaultLocale = "en_US.UTF-8";

  # services.xserver.enable = true;
  # services.desktopManager.plasma6.enable = true;
  # services.displayManager.sddm = {
  #   enable = true;
  #   wayland.enable = true;
  #   autoNumlock = true;
  #   settings.Autologin.Session = "plasma.desktop";
  #   settings.Autologin.User = "gustas";
  # };

  environment.variables = {
    TIMEFORMAT = "\nElapsed: %1R (%0lR)";
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

  hardware.opentabletdriver.enable = true;

  users.users.gustas = {
    isNormalUser = true;
    description = "Gustas";
    extraGroups = [ "networkmanager" "wheel" "docker" "adbusers" "input" ];
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    lm_sensors
    openssl
    ntfs3g
    file
    wget
  ];

  networking.firewall.enable = true;

  system.stateVersion = "23.11";

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
  };

  security.sudo.wheelNeedsPassword = false;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.package = pkgs-unstable.bluez;

  virtualisation.docker.enable = true;

  services.fstrim.enable = true;

  services.flatpak.enable = true;

  programs.adb.enable = true;

  # https://github.com/NixOS/nixpkgs/issues/207339#issuecomment-1747101887
  programs.dconf.enable = true;

  programs = {
    gamemode.enable = true;
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      gamescopeSession.enable = true;
    };
  };

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

  stylix = {
    enable = true;
    image = ../../assets/pandas.jpg;
    polarity = "light";
    base16Scheme = {
      name = "Terracotta";
      author = "Alexander Rossell Hayes (https://github.com/rossellhayes)";
      variant = "light";
      base00= "efeae8";
      base01= "dfd6d1";
      base02= "d0c1bb";
      base03= "c0aca4";
      base04= "59453d";
      base05= "473731";
      base06= "352a25";
      base07= "241c19";
      base08= "a75045";
      base09= "bd6942";
      base0A= "ce943e";
      base0B= "7a894a";
      base0C= "847f9e";
      base0D= "625574";
      base0E= "8d5968";
      base0F= "b07158";
    };
    cursor.package = pkgs.bibata-cursors;
    cursor.name = "Bibata-Modern-Ice";
    cursor.size = 24;
    fonts = {
      monospace= {
        name = "JetBrains Mono";
        package = pkgs.jetbrains-mono;
      };
      sansSerif = {
        name = "Noto Sans";
        package = pkgs.noto-fonts;
      };
      serif = {
        name = "Noto Serif";
        package = pkgs.noto-fonts;
      };
      sizes.applications = 10;
      # sizes.terminal = 10;
    };
  };

  specialisation.dark.configuration.stylix = {
    polarity = lib.mkForce "dark";
    base16Scheme = lib.mkForce {
      name = "Terracotta Dark";
      author = "Alexander Rossell Hayes (https://github.com/rossellhayes)";
      variant = "dark";
      base00= "241d1a";
      base01= "362b27";
      base02= "473933";
      base03= "594740";
      base04= "a78e84";
      base05= "b8a59d";
      base06= "cabbb5";
      base07= "dcd2ce";
      base08= "f6998f";
      base09= "ffa888";
      base0A= "ffc37a";
      base0B= "b6c68a";
      base0C= "c0bcdb";
      base0D= "b0a4c3";
      base0E= "d8a2b0";
      base0F= "f1ae97";
    };
  };
}
