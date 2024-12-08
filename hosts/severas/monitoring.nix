{ config, ... }:

let
  domain = "grafana.severas.lan";
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
        enabledCollectors = [ "systemd" ];
      };

      zfs = {
        enable = true;
        extraFlags = [ "--web.disable-exporter-metrics" ];
      };
    };

    scrapeConfigs = [
      {
        job_name = "severas";
        scrape_interval = "15s";
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
      "--enable_metrics=cpu,disk,diskIO,memory,network,oom_event,process"
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
}
