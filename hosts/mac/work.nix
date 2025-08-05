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

  default-browser-set = pkgs.writeScriptBin "default-browser-set" ''
    #!/usr/bin/env osascript

    on run argv
     do shell script "/opt/homebrew/bin/defaultbrowser " & item 1 of argv
     try
      tell application "System Events"
       tell application process "CoreServicesUIAgent"
        tell window 1
         tell (first button whose name starts with "use")
          perform action "AXPress"
         end tell
        end tell
       end tell
      end tell
     end try
    end run
  '';

  default-browser-toggle = pkgs.writeShellScriptBin "default-browser-toggle" ''
    current=$(/opt/homebrew/bin/defaultbrowser | grep '*' | cut -f2 -d ' ')

    if [ "$current" = "firefox" ]; then
        new_default='librewolf';
    elif [ "$current" = "librewolf" ]; then
        new_default='firefox';
    else
        echo "Unexpected result: '$current'"
        exit 1
    fi

    echo "Setting $new_default as the default browser"
    ${default-browser-set}/bin/default-browser-set "$new_default"
  '';
in
{
  nixpkgs.config.permittedInsecurePackages = [
    "dotnet-sdk-6.0.428"
  ];

  services.skhd.skhdConfig = ''
    ctrl + alt - b : ${default-browser-toggle}/bin/default-browser-toggle
  '';

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
      default-browser-toggle
      dotnet-sdks
      nodejs_24
      slack
      terraform-old-pkgs.terraform
    ];

    programs.ssh.matchBlocks."github.com".identityFile = "~/.ssh/github-trafi";

    programs.git.includes = lib.mkAfter [
      {
        condition = "gitdir:~/trafi/";
        contents = {
          core.sshCommand = "ssh -i ~/.ssh/github-trafi";
          user = {
            email = "gustas.klevinskas@trafi.com";
            name = "Gustas Klevinskas";
          };
        };
      }
    ];
  };
}
