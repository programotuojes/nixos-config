{ config, hidden, pkgs, ... }:

let
  domain = "grafana.severas.lan";
  scrape_interval = "15s";
in
{
  services.grafana = {
    enable = true;

    settings = {
      users = {
        default_theme = "system";
      };

      server = {
        enable_gzip = true;
        domain = domain;
      };

      security = {
        admin_password = "$__file{/var/keys/grafana-admin}";
        disable_gravatar = true;
      };

      database = {
        user = "grafana";
        type = "postgres";
        host = "/run/postgresql";
        high_availability = false;
      };

      analytics = {
        reporting_enabled = false;
        feedback_links_enabled = false;
        check_for_updates = false;
      };
    };
  };

  services.prometheus = {
    enable = true;

    exporters = {
      node = {
        enable = true;
        disabledCollectors = [
          "arp"
          "schedstat"
          "zfs"
        ];
      };

      zfs = {
        enable = true;
        extraFlags = [ "--web.disable-exporter-metrics" ];
      };
    };

    scrapeConfigs = [
      {
        job_name = "severas";
        scrape_interval = scrape_interval;
        static_configs = [{
          targets = [
            "127.0.0.1:${toString config.services.prometheus.exporters.node.port}"
            "127.0.0.1:${toString config.services.prometheus.exporters.zfs.port}"
            "127.0.0.1:${toString config.services.cadvisor.port}"
          ];
        }];
      }
    ];
  };

  services.cadvisor = {
    enable = true;
    port = 9550;
    extraOptions = [
      "--store_container_labels=false"
      "--disable_root_cgroup_stats=true"
      "--housekeeping_interval=${scrape_interval}"
      "--enable_metrics=cpu,diskIO,memory"
    ];
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "grafana" ];
    ensureUsers = [
      {
        name = config.services.grafana.settings.database.user;
        ensureDBOwnership = true;
      }
    ];
  };

  services.nginx = {
    enable = true;
    virtualHosts.${domain}.locations."/" =
      let
        port = toString config.services.grafana.settings.server.http_port;
      in
      {
        proxyPass = "http://127.0.0.1:${port}";
        proxyWebsockets = true;
      };
  };

  programs.msmtp = {
    enable = true;
    setSendmail = true;
    defaults = {
      aliases = "/etc/aliases";
      tls_trust_file = "/etc/ssl/certs/ca-certificates.crt";
      tls = "on";
      auth = "login";
      tls_starttls = "off";
    };
    accounts = {
      default = {
        host = hidden.smtp.server;
        port = hidden.smtp.port;
        passwordeval = "cat ${hidden.smtp.password_file}";
        user = hidden.smtp.username;
        from = "Severas <severas@${hidden.smtp.host}>";
        domain = hidden.smtp.host;
      };
    };
  };

  environment.etc.aliases.text = ''
    default: ${hidden.administrator_email}
  '';

  services.zfs.zed.settings = {
    ZED_DEBUG_LOG = "/tmp/zed.debug.log";
    ZED_EMAIL_ADDR = [ "root" ];
    ZED_EMAIL_PROG = "${pkgs.msmtp}/bin/msmtp";
    ZED_EMAIL_OPTS = "@ADDRESS@";

    ZED_NOTIFY_INTERVAL_SECS = 3600;
    ZED_NOTIFY_VERBOSE = true;

    ZED_USE_ENCLOSURE_LEDS = true;
    ZED_SCRUB_AFTER_RESILVER = true;
  };

  services.zfs.zed.enableMail = false; # This option does not work; will return error
}
