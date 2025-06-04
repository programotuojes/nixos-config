{ pkgs, lib, ... }:

let
  dotnet-sdks = with pkgs.dotnetCorePackages; combinePackages [
    sdk_6_0
    sdk_8_0
    sdk_9_0
  ];
  terraform-old-pkgs = import
    (builtins.fetchGit {
      name = "terraform-old-trafi";
      url = "https://github.com/NixOS/nixpkgs/";
      ref = "refs/heads/nixpkgs-unstable";
      rev = "d1c3fea7ecbed758168787fe4e4a3157e52bc808";
    })
    { system = "aarch64-darwin"; };
in
{
  nixpkgs.config.permittedInsecurePackages = [
    "dotnet-sdk-6.0.428"
  ];

  home-manager.users.gustas = {
    programs.bash = {
      bashrcExtra = ''
        export PATH=$PATH:/Users/gustas/.dotnet/tools
      '';
      sessionVariables = {
        DOTNET_ROOT = "${dotnet-sdks}/share/dotnet";
      };
    };

    home.packages = with pkgs; [
      aws-vault
      awscli2
      dotnet-sdks
      nodejs_23
      terraform-old-pkgs.terraform
    ];

    programs.git.includes = lib.mkAfter [
      {
        condition = "gitdir:~/trafi/";
        contents = {
          user = {
            email = "gustas.klevinskas@trafi.com";
            name = "Gustas Klevinskas";
          };
        };
      }
    ];
  };
}
