{ config, pkgs, hidden, ... }:

{
  imports = [
    ./git.nix
    ./hardware-configuration.nix
    ./media.nix
    ./monitoring.nix
    ./network.nix
    ./nextcloud.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.loader.timeout = 0;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelModules = [ "coretemp" "nct6775" ];

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  boot.zfs.extraPools = [ "pool" ];
  services.fstrim.enable = true;

  hardware.cpu.intel.updateMicrocode = true;

  time.timeZone = "Europe/Vilnius";
  i18n.defaultLocale = "en_US.UTF-8";

  nixpkgs.config.allowUnfree = true;

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  users.users.root.openssh.authorizedKeys.keys = [ hidden.lbook_ssh_key ];

  environment.systemPackages = with pkgs; [
    file
    git
    git-crypt
    htop-vim
    lm_sensors
    ntfs3g
    tree

    # Neovim deps
    cargo
    gcc
    nixd
    nixpkgs-fmt
    ripgrep
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
  };

  services.postgresql = {
    package = pkgs.postgresql_16;
    dataDir = "/pool/postgres/16";
  };

  system.stateVersion = "23.05";
}
