{ config, pkgs, lib, hidden, ... }:

{
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud31;

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

      ${hidden.collabora_domain} = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://[::1]:${toString config.services.collabora-online.port}";
          proxyWebsockets = true;
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 
    config.services.nginx.defaultHTTPListenPort
    config.services.nginx.defaultSSLListenPort
  ];

  services.postgresql.enable = true;

  # Needed for "Allow list for WOPI requests"
  # https://diogotc.com/blog/collabora-nextcloud-nixos
  networking.hosts = {
    "127.0.0.1" = [ hidden.nextcloud_domain hidden.collabora_domain ];
    "::1" = [ hidden.nextcloud_domain hidden.collabora_domain ];
  };

  services.collabora-online = {
    enable = true;
    settings = {
      ssl = {
        enable = false;
        termination = true;
      };

      net = {
        listen = "loopback";
        post_allow.host = ["::1"];
      };

      storage.wopi = {
        "@allow" = true;
        host = [hidden.nextcloud_domain];
      };

      server_name = hidden.collabora_domain;
      admin_console.enable = false;
      remote_font_config.url = "https://${hidden.nextcloud_domain}/apps/richdocuments/settings/fonts.json";
      fonts_missing.handling = "both";
    };
  };
}
