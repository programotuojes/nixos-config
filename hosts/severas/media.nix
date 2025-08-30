{ config, pkgs, hidden, ... }:

{
  networking.firewall.allowedTCPPorts = [
    config.services.nginx.defaultHTTPListenPort
  ];
  networking.firewall.allowedUDPPorts = [
    config.services.nginx.defaultHTTPListenPort
    # config.networking.wireguard.interfaces.wg-deluge.listenPort
  ];

  services.nginx =
    let
      domain = "tube.severas.lan";
    in
    {
      enable = true;
      proxyTimeout = "10m";
      clientMaxBodySize = "10G";
      virtualHosts.${domain}.locations = {
        "= /" = {
          return = "301 http://${domain}/web/index.html";
        };

        "/" = {
          proxyPass = "http://127.0.0.1:8096";
        };

        "/socket" = {
          proxyPass = "http://127.0.0.1:8096";
          proxyWebsockets = true;
        };
      };
      virtualHosts."deluge.severas.lan".locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.deluge.web.port}";
        };
      };
      virtualHosts.${hidden.immich_domain} = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://localhost:2283";
          proxyWebsockets = true;
        };
      };
    };

  services.deluge = {
    enable = true;
    declarative = true;
    openFirewall = true;
    dataDir = "/pool/torrents";
    authFile = "/var/keys/deluge-auth";

    web.enable = true;

    config = {
      # listen_interace = "wg-deluge";
      # listen_interaces = "wg-deluge";
      # outgoing_interace = "wg-deluge";
      # outgoing_interaces = "wg-deluge";
      download_location = "/pool/torrents";
      torrentfiles_location = "/pool/torrents/torrentfiles";
      copy_torrent_file = true;
      max_active_seeding = -1;
      max_active_downloading = -1;
      max_active_limit = -1;
      new_release_check = false;
      max_upload_speed = 2048.0;
    };
  };

  services.prometheus.exporters.deluge = rec {
    enable = true;
    group = config.services.deluge.group;
    exportPerTorrentMetrics = true;
    delugeUser = "gustas";
    delugePasswordFile = "${config.services.deluge.authFile} | grep ${delugeUser} | cut -d: -f2";
  };

  # networking.wireguard.interfaces.wg-deluge = {
  #   ips = [ "10.2.0.2/32" ];
  #   # dns = [ "10.2.0.1" ];
  #   privateKeyFile = "/var/keys/proton-private";
  #   listenPort = 51821;
  #
  #   peers = [
  #     {
  #       publicKey = "36G8+pInNcPK9F1TpHglWs9Pk5uJOY9o8SCNrCBgvHE=";
  #       allowedIPs = [ "10.2.0.2/32" ];
  #       endpoint = "89.222.96.158:51820";
  #     }
  #   ];
  # };

  services.jellyfin.enable = true;
  users.users.${config.services.jellyfin.user}.extraGroups = [ config.services.deluge.group ];

  boot.kernelParams = [ "i915.enable_guc=3" ];

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-compute-runtime
      intel-media-driver
      intel-ocl
      vpl-gpu-rt
    ];
  };

  users.users.${config.services.immich.user}.extraGroups = [ "nextcloud" ];

  services.immich = {
    enable = true;
    accelerationDevices = [ "/dev/dri/renderD128" ];
    mediaLocation = "/pool/immich";
  };
}
