{ config, pkgs, lib, hidden, ... }:

{
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud32;

    hostName = hidden.nextcloud_domain;
    https = true;

    home = "/pool/nextcloud";

    maxUploadSize = "10G";

    configureRedis = true;
    database.createLocally = true;

    config = {
      adminpassFile = "/var/keys/nextcloud-admin";
      dbtype = "pgsql";
    };

    settings = {
      "memories.exiftool" = "${lib.getExe pkgs.exiftool}";
      "memories.vod.ffmpeg" = "${pkgs.ffmpeg-headless}/bin/ffmpeg";
      "memories.vod.ffprobe" = "${pkgs.ffmpeg-headless}/bin/ffprobe";
      default_phone_region = "LT";
      log_type = "file";
      preview_ffmpeg_path = "${pkgs.ffmpeg-headless}/bin/ffmpeg";
      maintenance_window_start = 0;
    };

    phpOptions = {
      "opcache.interned_strings_buffer" = "24";
    };
  };

  systemd.services.nextcloud-cron.path = [ pkgs.perl ];

  security.acme = {
    acceptTerms = true;
    defaults.email = hidden.acme_email;
  };

  services.nginx = {
    enable = true;

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;

    virtualHosts = {
      ${hidden.nextcloud_domain} = {
        forceSSL = true;
        enableACME = true;
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 
    config.services.nginx.defaultHTTPListenPort
    config.services.nginx.defaultSSLListenPort
  ];

  services.postgresql.enable = true;
}
