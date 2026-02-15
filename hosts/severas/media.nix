{ config, pkgs, pkgs-unstable, hidden, lib, ... }:

let
  vpn = {
    table = "protonvpn";
    interface = "wg-p2p";
    ip = "10.2.0.2/32";
    gateway = "10.2.0.1";
  };
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
    virtualHosts."torrent.severas.lan".locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.qbittorrent.webuiPort}";
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

  networking.iproute2 = {
    enable = true;
    rttablesExtraConfig = "200 ${vpn.table}";
  };

  networking.wireguard.interfaces.${vpn.interface} = {
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
    wantedBy = [ "multi-user.target" ];
    after = [ "wireguard-${vpn.interface}.target" "qbittorrent.service" ];
    partOf = [ "qbittorrent.service" ];
    bindsTo = [ "qbittorrent.service" ];

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

          QBIT_PORT=${toString config.services.qbittorrent.webuiPort}
          DIR="/var/lib/proton-vpn-port-forward"
          mkdir -p "$DIR"
          rm -f "$DIR/tcp-port" "$DIR/udp-port"

          set_listen_port() {
              touch /var/keys/qbittorrent/cookie
              chmod 600 /var/keys/qbittorrent/cookie
              ${pkgs.curl}/bin/curl -s --cookie-jar /var/keys/qbittorrent/cookie --data "username=admin&password=$(cat /var/keys/qbittorrent/admin-pass)" http://127.0.0.1:$QBIT_PORT/api/v2/auth/login
              ${pkgs.curl}/bin/curl -s -b /var/keys/qbittorrent/cookie "http://127.0.0.1:$QBIT_PORT/api/v2/app/setPreferences" --data "json={\"listen_port\": $1}"
          }

          renew_port() {
              protocol="$1"
              port_file="$DIR/$protocol-port"
              touch "$port_file"

              result="$(${pkgs.libnatpmp}/bin/natpmpc -a 1 0 "$protocol" 60 -g ${vpn.gateway})"
              new_port="$(echo "$result" | ${pkgs.ripgrep}/bin/rg --only-matching --replace '$1' 'Mapped public port (\d+) protocol ... to local port 0 lifetime 60')"

              if [ -z "$new_port" ]; then
                  echo "Failed to get new $protocol port"
                  echo "Error: $result"
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
                  set_listen_port "$new_port"
                  echo "Didn't find a previous $protocol port, will wait for next loop"
                  return
              fi

              if [ "$new_port" -ne "$old_port" ]; then
                  set_listen_port "$new_port"
                  if ${iptables} -C ${chain} -p "$protocol" --dport "$old_port" -j ACCEPT 2>/dev/null; then
                      echo "Closing old $protocol port $old_port"
                      ${iptables} -D ${chain} -p "$protocol" --dport "$old_port" -j ACCEPT
                  fi
              fi
          }

          while true; do
              renew_port tcp
              renew_port udp
              sleep 50
          done
        '';
        ExecStopPost = "${iptables} -F ${chain}";
      };
  };

  services.jellyfin.enable = true;
  users.users.${config.services.jellyfin.user}.extraGroups = [ config.services.qbittorrent.group ];

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
    database.enableVectors = false;
  };

  environment.systemPackages = [
    pkgs-unstable.immich-go
  ];

  services.qbittorrent = {
    enable = true;
    profileDir = "/pool/torrents";
    serverConfig = {
      LegalNotice.Accepted = true;
      Core.AutoDeleteAddedTorrentFile = "Never";
      Network.PortForwardingEnabled = false;
      BitTorrent.Session = {
        AnonymousModeEnabled = true;
        DisableAutoTMMByDefault = false;
        GlobalUPSpeedLimit = 2048;
        IgnoreLimitsOnLAN = true;
        Interface = vpn.interface;
        MaxActiveCheckingTorrents = -1;
        QueueingSystemEnabled = false;
        TorrentExportDirectory = "/pool/torrents/qBittorrent/torrentfiles";
      };
      Preferences = {
        General.StatusbarExternalIPDisplayed = true;
        WebUI = {
          Address = "127.0.0.1";
          Password_PBKDF2 = hidden.passwords.qbittorrent;
        };
      };
    };
  };
}
