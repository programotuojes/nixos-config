{ pkgs, hidden, inputs, specialArgs, config, ... }:

{
  imports = [
    ../../users/gustas.nix
    ./git.nix
    ./hardware-configuration.nix
    ./media.nix
    ./minecraft.nix
    ./monitoring.nix
    ./nextcloud.nix
    inputs.home-manager.nixosModules.default
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = specialArgs;
  };

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
  services.zfs.autoScrub.enable = true;
  services.fstrim.enable = true;

  hardware.cpu.intel.updateMicrocode = true;

  time.timeZone = "Europe/Vilnius";
  i18n.defaultLocale = "en_US.UTF-8";

  nixpkgs.config.allowUnfree = true;

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  users.users.gustas = {
    extraGroups = [ config.services.deluge.group ];
    openssh.authorizedKeys.keys = [
      hidden.lbook_ssh_key
      hidden.mac_ssh_key
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM65USbIdgavJrVAn52udFA2Fripx/evPMMF0e2TWTJO" # Bitwarden
    ];
  };

  environment.systemPackages = with pkgs; [
    lm_sensors
  ];

  services.postgresql = {
    package = pkgs.postgresql_16;
    dataDir = "/pool/postgres/16";
  };

  system.stateVersion = "23.05";

  virtualisation.docker = {
    enable = true;
    package = pkgs.docker_27;
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

          privateKeyFile = "/var/keys/wireguard/pk";
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
