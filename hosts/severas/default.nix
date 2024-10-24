{ pkgs, hidden, ... }:

{
  imports = [
    ./git.nix
    ./hardware-configuration.nix
    ./media.nix
    ./monitoring.nix
    ./nextcloud.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nix.optimise.automatic = true;
  nix.optimise.dates = [ "Mon 04:00" ];

  nix.gc.automatic = true;
  nix.gc.dates = "Tue 04:00";
  nix.gc.options = "--delete-older-than 7d";

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

  nixpkgs.overlays = [
    (final: prev: {
      # Allow to run as root user
      nh = prev.nh.overrideAttrs (oldAttrs: {
        patches = oldAttrs.patches ++ [
          (prev.fetchpatch2 {
            url = "https://github.com/PaulGrandperrin/nh-root/commit/bea0ce26e4b1a260e285164c49456d70d346c924.patch";
            hash = "sha256-w8/nfMkk/CeOaLW2XIUvKs7//bGm11Cj6ifyTYzlqjo=";
          })
        ];
      });
    })
  ];

  environment.systemPackages = with pkgs; [
    file
    git
    git-crypt
    htop-vim
    lm_sensors
    nh
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

  virtualisation.docker = {
    enable = true;
    package = pkgs.docker_27;
  };

  services.nginx = {
    proxyTimeout = "600s";
    clientMaxBodySize = "200M";
    virtualHosts.${hidden.immich_domain} = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:2283";
        proxyWebsockets = true;
      };
    };
  };

  networking =
    let
      interface = "enp0s31f6";
    in
    {
      hostName = "severas";
      hostId = "9c295bfe";

      nat.enable = true;
      nat.externalInterface = interface;
      nat.internalInterfaces = [ "wg0" ];
      firewall.allowedUDPPorts = [ 51820 ];

      wireguard.interfaces = {
        wg0 = {
          ips = [ "10.100.0.1/24" ];
          listenPort = 51820;

          postSetup = ''
            ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o ${interface} -j MASQUERADE
          '';

          postShutdown = ''
            ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o ${interface} -j MASQUERADE
          '';

          privateKeyFile = "/var/keys/wireguard-pk";
          generatePrivateKeyFile = true;

          peers = [
            {
              name = "gustafonas";
              publicKey = "ZSKx6E5u1Vzu4nARcodruKwQKnyQzduMNeVmXZCunFw=";
              presharedKeyFile = "/var/keys/wireguard/gustafonas/psk";
              allowedIPs = [ "10.100.0.2/32" ];
            }
          ];
        };
      };
    };
}
