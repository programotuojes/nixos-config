{ pkgs, hidden, ... }:

let
  minikube-interface = "minikube";
in
{
  security.pki.certificates = [
    hidden.work.cert
  ];

  networking.hosts."192.168.49.2" = [
    "local"
    "influxdb.local"
    "rabbitmq.local"
  ];

  networking.firewall.trustedInterfaces = [
    minikube-interface
    "docker0"
  ];

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_15;
    enableTCPIP = true;
    authentication = ''
      local benchmark postgres trust
      host  postgres  postgres    192.168.49.0/24 password
      host  postgres  runtime     192.168.49.0/24 password
      host  postgres  masstransit 192.168.49.0/24 password
      host  postgres  postgres    172.17.0.1/16   password
    '';
    initialScript = pkgs.writeText "work-pass" "ALTER USER postgres PASSWORD 'DevelopmentDBpsql';";
  };

  environment.variables = {
    PAT = hidden.work.pat;
    ServiceBaseUrl = "https://local";
    InfluxDB__Url = "https://influxdb.local";
    DOTNET_CLI_TELEMETRY_OPTOUT = "1";
  };

  # For Puppeteer's Chrome executable
  # Not every library is needed for it, this is just a list of common libs
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    fuse
    fuse3
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    curl
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    libGL
    libappindicator-gtk3
    libdrm
    libnotify
    libpulseaudio
    libuuid
    libusb1
    xorg.libxcb
    libxkbcommon
    mesa
    nspr
    nss
    pango
    pipewire
    systemd
    icu
    openssl
    xorg.libX11
    xorg.libXScrnSaver
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXrandr
    xorg.libXrender
    xorg.libXtst
    xorg.libxkbfile
    xorg.libxshmfence
    zlib
  ];

  systemd.services = {
    minikube = {
      path = [ pkgs.docker ];
      description = "Minikube";
      requires = [ "docker.socket" "docker.service" ];
      after = [ "docker.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = "yes";
        ExecStart = "${pkgs.minikube}/bin/minikube start --cpus 10 --memory 10G --addons ingress,dashboard --network minikube";
        ExecStop = "${pkgs.minikube}/bin/minikube stop";
        User = "gustas";
        Group = "users";
      };
      preStart = ''
        if ! ${pkgs.iproute2}/bin/ip a show dev ${minikube-interface}; then
            ${pkgs.docker}/bin/docker network create --driver=bridge --subnet='192.168.49.0/24' --gateway='192.168.49.1' -o --ip-masq -o --icc -o com.docker.network.bridge.name='${minikube-interface}' minikube
        fi
      '';
    };

    minikube-dashboard = {
      path = [ pkgs.docker ];
      description = "Minikube dashboard";
      requires = [ "minikube.service" ];
      after = [ "minikube.service" ];
      wantedBy = [ "minikube.service" ];
      serviceConfig = {
        ExecStart = "${pkgs.minikube}/bin/minikube dashboard --port 50000 --url";
        User = "gustas";
        Group = "users";
      };
    };
  };
}
