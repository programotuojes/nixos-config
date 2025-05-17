{ pkgs, lib, ... }:

let
  dotnet-sdks = with pkgs.dotnetCorePackages; combinePackages [
    sdk_6_0
    sdk_8_0
    sdk_9_0
  ];
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
    ];

    programs.git.includes = lib.mkAfter [
      {
        condition = "gitdir:~/trafi/";
        contents = {
          user = {
            email = "gustas.klevinskas@trafi.com";
            name = "Gustas Klevinskas";
          };
	  core = {
	    sshCommand = "ssh -i ~/.ssh/github";
	  };
        };
      }
    ];
  };
}
