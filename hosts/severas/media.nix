{ config, pkgs, hidden, ... }:

let
  vpn = {
    table = "protonvpn";
    interface = "wg-deluge";
    ip = "10.2.0.2/32";
    gateway = "10.2.0.1";
  };
  delugeUser = "gustas";
in
{
  networking.firewall.allowedTCPPorts = [
    config.services.nginx.defaultHTTPListenPort
  ];
  networking.firewall.allowedUDPPorts = [
    config.services.nginx.defaultHTTPListenPort
  ];

  services.nginx = {
    enable = true;
    proxyTimeout = "10m";
    clientMaxBodySize = "10G";
    virtualHosts.${hidden.domains.jellyfin} = {
      forceSSL = true;
      enableACME = true;
      locations = {
        "= /" = {
          return = "301 https://${hidden.domains.jellyfin}/web/index.html";
        };

        "/" = {
          proxyPass = "http://127.0.0.1:8096";
        };

        "/socket" = {
          proxyPass = "http://127.0.0.1:8096";
          proxyWebsockets = true;
        };
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
    package = pkgs.deluged;
    declarative = true;
    dataDir = "/pool/torrents";
    authFile = "/var/keys/deluge-auth";

    web.enable = true;

    config = {
      listen_interface = vpn.interface;
      outgoing_interface = vpn.interface;
      download_location = "/pool/torrents";
      torrentfiles_location = "/pool/torrents/torrentfiles";
      copy_torrent_file = true;
      max_active_seeding = -1;
      max_active_downloading = -1;
      max_active_limit = -1;
      new_release_check = false;
      max_upload_speed = 2048.0;

      upnp = false;
      natpmp = false;
      random_port = false;
    };
  };

  systemd.services.deluged.serviceConfig.MemoryHigh = "5G";

  systemd.services.deluged-restart = {
    description = "Fixes 'Error: Host not found (authoritative)' on reboot";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = [ "/run/current-system/sw/bin/systemctl restart deluged.service" ];
    };
  };
  systemd.timers.deluged-restart = {
    description = "Fixes 'Error: Host not found (authoritative)' on reboot";
    wantedBy = [ "multi-user.target" ];
    timerConfig = {
      OnBootSec = "20s";
      Unit = "deluged-restart.service";
    };
  };

  services.prometheus.exporters.deluge = {
    enable = true;
    group = config.services.deluge.group;
    exportPerTorrentMetrics = true;
    delugeUser = delugeUser;
    delugePasswordFile = "${config.services.deluge.authFile} | grep ${delugeUser} | cut -d: -f2";
  };

  networking.iproute2 = {
    enable = true;
    rttablesExtraConfig = "200 ${vpn.table}";
  };

  networking.wireguard.interfaces.${vpn.interface} =
    {
      ips = [ vpn.ip ];
      listenPort = 51821;
      table = vpn.table;
      privateKeyFile = "/var/keys/proton-private";

      postSetup = ''
        ${pkgs.iproute2}/bin/ip rule add from ${vpn.ip} table ${vpn.table} priority 1000
        ${pkgs.iproute2}/bin/ip route add ${vpn.gateway} dev ${vpn.interface}
      '';

      postShutdown = ''
        ${pkgs.iproute2}/bin/ip rule del from ${vpn.ip} table ${vpn.table}
        ${pkgs.iproute2}/bin/ip route del ${vpn.gateway} dev ${vpn.interface}
      '';

      peers = [
        {
          publicKey = "36G8+pInNcPK9F1TpHglWs9Pk5uJOY9o8SCNrCBgvHE=";
          allowedIPs = [ "0.0.0.0/0" "::/0" ];
          endpoint = "89.222.96.158:51820";
        }
      ];
    };

  systemd.services.proton-vpn-port-forward = {
    description = "Proton VPN port forwarding";
    after = [ "wireguard-${vpn.interface}.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig =
      let
        iptables = "${pkgs.iptables}/bin/iptables";
        chain = "proton-vpn-fw";
      in
      {
        Type = "exec";
        Restart = "on-failure";
        ExecStart = pkgs.writeShellScript "proton-natpmp" ''
          set -euo pipefail

          ${iptables} -N ${chain} 2>/dev/null || true
          if ! ${iptables} -C INPUT -i ${vpn.interface} -j ${chain} 2>/dev/null; then
              ${iptables} -I INPUT 1 -i ${vpn.interface} -j ${chain}
          fi

          DIR="/var/lib/proton-vpn-port-forward"
          mkdir -p "$DIR"

          DELUGE_PASS="$(grep ${delugeUser} ${config.services.deluge.authFile} | cut -d: -f2)"

          set_deluge_port() {
              ${pkgs.deluge}/bin/deluge-console -U '${delugeUser}' -P "$DELUGE_PASS" "config -s listen_ports ($1, $1) ; exit"
          }

          renew_port() {
              protocol="$1"
              port_file="$DIR/$protocol-port"

              result="$(${pkgs.libnatpmp}/bin/natpmpc -a 1 0 "$protocol" 60 -g ${vpn.gateway})"
              new_port="$(echo "$result" | ${pkgs.ripgrep}/bin/rg --only-matching --replace '$1' 'Mapped public port (\d+) protocol ... to local port 0 lifetime 60')"

              if [ -z "$new_port" ]; then
                  echo "Failed to get new $protocol port"
                  echo "$result"
                  exit 1
              fi

              echo "Received $protocol port $new_port"
              old_port="$(cat "$port_file")"
              echo "$new_port" > "$port_file"

              if ! ${iptables} -C ${chain} -p "$protocol" --dport "$new_port" -j ACCEPT 2>/dev/null; then
                  echo "Opening $protocol port $new_port in the firewall"
                  ${iptables} -I ${chain} -p "$protocol" --dport "$new_port" -j ACCEPT
              fi

              if [ -z "$old_port" ]; then
                  set_deluge_port "$new_port"
                  echo "Didn't find a previous $protocol port, will wait for next loop"
                  return
              fi

              if [ "$new_port" -ne "$old_port" ]; then
                  set_deluge_port "$new_port"
                  if ${iptables} -C ${chain} -p "$protocol" --dport "$old_port" -j ACCEPT 2>/dev/null; then
                      echo "Closing old $protocol port $old_port"
                      ${iptables} -D ${chain} -p "$protocol" --dport "$old_port" -j ACCEPT
                  fi
              fi
          }

          while true; do
            renew_port udp
            renew_port tcp
            sleep 50
          done
        '';
        ExecStopPost = "${iptables} -F ${chain}";
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
