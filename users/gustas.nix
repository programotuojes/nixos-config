{ pkgs, ... }:

{
  environment.variables = {
    TIMEFORMAT = "\nElapsed: %1R (%0lR)";
  };

  users.users.gustas = {
    isNormalUser = true;
    description = "Gustas";
    extraGroups = [ "wheel" "docker" ];
  };

  home-manager.users.gustas = {
    programs.home-manager.enable = true;
    home.username = "gustas";
    home.homeDirectory = "/home/gustas";
    home.stateVersion = "23.11";

    home.shellAliases = {
      grep = "grep --color=auto";
      ip = "ip --color=auto";
    };

    programs.git = {
      enable = true;
      extraConfig = {
        init.defaultBranch = "main";
        push.autoSetupRemote = true;
      };
      aliases.sw = "switch";
      includes = [
        {
          condition = "gitdir:~/";
          contents.user = {
            email = "programotuojes@users.noreply.github.com";
            name = "Gustas Klevinskas";
          };
        }
      ];
    };

    programs.bash = {
      enable = true;
      bashrcExtra = ''
        eval "$(zoxide init bash)"
      '';
    };

    programs.readline = {
      enable = true;
      extraConfig = ''
        set completion-ignore-case on
      '';
    };

    home.packages = with pkgs; [
      file
      git-crypt
      nh
      nixd
      nixpkgs-fmt
      tree
      wget
      zoxide
    ];
  };
}
