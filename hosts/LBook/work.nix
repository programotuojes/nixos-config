{ pkgs, pkgs-unstable, hidden, lib, ... }:

let
  minikube-interface = "minikube";
  user = "gustas";
in
{
  security.pki.certificates = [ hidden.work.cert ];

  networking.hosts."192.168.49.2" = [
    "local"
    "influxdb.local"
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
        User = user;
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
        User = user;
        Group = "users";
      };
    };
  };

  home-manager.users.${user} = {
    home.file."artifacts-credprovider" = {
      target = ".nuget/plugins/netcore/CredentialProvider.Microsoft/";
      recursive = true;
      source = pkgs.fetchzip rec {
        name = "artifacts-credprovider";

        version = "1.0.9";
        hash = "sha256-EwhRcFuXVwI9Q8kuy836mGasTGRCsGSRMqrS+RKF4IE=";

        url = "https://github.com/microsoft/artifacts-credprovider/releases/download/v${version}/Microsoft.NuGet.CredentialProvider.tar.gz";
        stripRoot = false;
        postFetch = ''
          shopt -s extglob
          rm -rv $out/!(plugins)
          mv $out/plugins/netcore/CredentialProvider.Microsoft/* $out
          rm -rv $out/plugins
        '';
      };
    };

    home.packages = with pkgs; [
      azure-cli
      pkgs-unstable.dotnet-sdk_8
      gp-saml-gui
      grype
      kubectl
      kubelogin
      kubernetes-helm
      minikube
      (jetbrains.rider.overrideAttrs (prev: {
        # Fix "java.io.FileNotFoundException: No 'linux-x64/dotnet/dotnet' found in locations".
        # This manifests as "No protocolHost for the application [Plugin: com.intellij]" later on in logs
        # and by not being able to open any project.
        # More info https://github.com/corngood/nixpkgs/blob/fd3d60b2edbb0333c8ae925d053cf56d0438c379/nixos/doc/manual/release-notes/rl-2411.section.md?plain=1#L727C1-L730C16
        postInstall = (prev.postInstall or "") + ''
          for dir in $out/rider/lib/ReSharperHost/linux-*; do
            rm -rf $dir/dotnet
            ln -s ${dotnetCorePackages.dotnet_9.runtime.unwrapped}/share/dotnet $dir/dotnet
          done
        '';
      }))
      syft
      teams-for-linux
      ungoogled-chromium
    ];

    xdg.desktopEntries."firefox-work" = {
      name = "Firefox (Work)";
      genericName = "Web Browser";
      exec = "firefox -P Work --class=firefox-work %U";
      icon = "firefox";
      startupNotify = true;
      categories = [ "Network" "WebBrowser" ];
      settings.StartupWMClass = "firefox-work";
      actions = {
        new-window = {
          exec = "firefox -P Work --new-window --class=firefox-work %U";
          name = "New Window";
        };
        new-private-window = {
          exec = "firefox -P Work --private-window --class=firefox-work %U";
          name = "New Private Window";
        };
      };
    };

    programs.ssh.matchBlocks."ssh.dev.azure.com".identityFile = "~/.ssh/azure-devops";

    programs.git.includes = lib.mkAfter [
      {
        condition = "gitdir:~/bentley/";
        contents = {
          user = {
            email = "gustas.klevinskas@bentley.com";
            name = "Gustas Klevinskas";
          };
        };
      }
    ];
  };
}
