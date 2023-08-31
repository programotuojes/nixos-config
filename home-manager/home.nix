{ config, pkgs, ... }:

{
    imports = [
        ./artifacts-credprovider.nix
        ./firefox.nix
        ./lbook.nix
    ];

    home.username = "gustas";
    home.homeDirectory = "/home/gustas";

    home.stateVersion = "23.05";

    home.packages = [ ];

    home.shellAliases = {
        grep = "grep --color=auto";
        ip = "ip --color=auto";
    };

    programs.home-manager.enable = true;
    programs.bash.enable = true;
    programs.ssh.enable = true;
    programs.ssh.matchBlocks = {
        "ssh.dev.azure.com".identityFile = "~/.ssh/azure-devops";
        "github.com".identityFile = "~/.ssh/github";
        "severas" = {
            identityFile = "~/.ssh/severas";
            user = "root";
        };
    };

    programs.git.extraConfig.init.defaultBranch = "master";
}
