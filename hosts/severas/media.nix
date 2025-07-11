{ config, pkgs, hidden, ... }:

{
  networking.firewall.allowedTCPPorts = [
    config.services.nginx.defaultHTTPListenPort
    8096 # Android client. Remove once DNS is set up
  ];
  networking.firewall.allowedUDPPorts = [
    # Service discovery ports (https://jellyfin.org/docs/general/networking/index.html#static-ports)
    1900
    7359
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

    web = {
      enable = true;
      openFirewall = true;
    };

    config = {
      allow_remote = true;
      random_port = false;
      daemon_port = 58846;
      download_location = "/pool/torrents";
      torrentfiles_location = "/pool/torrents/torrentfiles";
      copy_torrent_file = true;
      upnp = false;
      natpmp = false;
      max_active_seeding = -1;
      max_active_downloading = -1;
      max_active_limit = -1;
    };
  };

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
