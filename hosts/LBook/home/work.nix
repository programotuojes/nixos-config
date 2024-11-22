{ pkgs, pkgs-unstable, ... }:

{
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

  home.packages = with pkgs; [
    azure-cli
    pkgs-unstable.dotnet-sdk_8
    gp-saml-gui
    grype
    jetbrains-toolbox
    kubectl
    kubelogin
    kubernetes-helm
    minikube
    (pkgs-unstable.jetbrains.rider.overrideAttrs (prev: {
      # Fix "java.io.FileNotFoundException: No 'linux-x64/dotnet/dotnet' found in locations".
      # This manifests as "No protocolHost for the application [Plugin: com.intellij]" later on in logs
      # and by not being able to open any project.
      # More info https://github.com/corngood/nixpkgs/blob/fd3d60b2edbb0333c8ae925d053cf56d0438c379/nixos/doc/manual/release-notes/rl-2411.section.md?plain=1#L727C1-L730C16
      postInstall = (prev.postInstall or "") + ''
        for dir in $out/rider/lib/ReSharperHost/linux-*; do
          rm -rf $dir/dotnet
          ln -s ${pkgs-unstable.dotnetCorePackages.dotnet_9.runtime.unwrapped}/share/dotnet $dir/dotnet
        done
      '';
    }))
    syft
    teams-for-linux
    (callPackage ../../../packages/tracy.nix { })
    ungoogled-chromium
  ];
}
