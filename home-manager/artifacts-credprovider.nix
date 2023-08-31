{ pkgs, lib, ... }:

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
}
