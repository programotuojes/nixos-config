{ pkgs, lib, ... }:

{
  environment.variables = {
    TIMEFORMAT = "\nElapsed: %1R s (%0lR)";
  };

  users.users.gustas = lib.mkIf pkgs.stdenv.isLinux {
    isNormalUser = true;
    description = "Gustas";
    extraGroups = [ "wheel" "docker" ];
  };

  home-manager.users.gustas = {
    programs.home-manager.enable = true;
    home.username = "gustas";
    home.homeDirectory = if pkgs.stdenv.isLinux
      then "/home/gustas"
      else "/Users/gustas";
    home.stateVersion = "23.11";

    home.shellAliases = {
      grep = "grep --color=auto";
      ip = "ip --color=auto";
      l = "ls -lah";
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
          contents = {
	    user = {
              email = "programotuojes@users.noreply.github.com";
              name = "Gustas Klevinskas";
            };
	    core.sshCommand = "ssh -i ~/.ssh/github-programotuojes";
	  };
        }
      ];
    };

    programs.bash = {
      enable = true;
      initExtra = ''
        PROMPT_COMMAND='PS1_CMD1=$(git branch --show-current 2>/dev/null)'
	PS1='\n╭ \[\e[38;5;172m\][\u@\h]\[\e[0m\] \[\e[38;5;111m\]\w\[\e[0m\] \[\e[38;5;102m\]''${PS1_CMD1}\n\[\e[0m\]╰ \$ '
        eval "$(zoxide init bash)"
      '';
    };

    programs.readline = {
      enable = true;
      extraConfig = ''
        set completion-ignore-case on
      '';
    };

    programs.neovim = {
      enable = true;
      defaultEditor = true;
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

      # Neovim stuff
      cargo
      gcc
      ripgrep
      unzip
    ];
  };
}
