{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./nvidia.nix
      ./work.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "LBook";

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Vilnius";
  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  services.xserver.displayManager.sddm = {
    enable = true;
    settings.Autologin.Session = "plasma.desktop";
    settings.Autologin.User = "gustas";
  };

  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  services.printing.enable = true;

  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    #jack.enable = true;
  };

  users.users.gustas = let
      unstable = import <nixos-unstable> { config = config.nixpkgs.config; };
  in {
      isNormalUser = true;
      description = "Gustas";
      extraGroups = [ "networkmanager" "wheel" "docker" ];
      packages = with pkgs; [
          firefox
          spotify
          obsidian
          deluge
          vlc
          kate
          git
          discord
	  gimp
          libreoffice-qt
          gcc xclip ripgrep cargo unzip #binutils # Neovim
          go gnumake # Local Minikube development

          # Work
          dotnet-sdk_7
          dotnet-sdk
          jetbrains.rider
          minikube kubectl kubernetes-helm azure-cli
          unstable.teams-for-linux
      ];
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    lm_sensors
    openssl
    ntfs3g
    file
    fuse
  ];

  networking.firewall.enable = true;
  #networking.firewall.allowedTCPPorts = [ 8000 ];

  system.stateVersion = "23.05";

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
}
