{ pkgs, inputs, specialArgs, hidden, ... }:

{
  imports = [
    ../../users/gustas.nix
    ./work.nix
    inputs.home-manager.darwinModules.default
  ];

  nix = {
    settings.experimental-features = "nix-command flakes";
  };

  nixpkgs = {
    hostPlatform = "aarch64-darwin";
    config.allowUnfree = true;
  };

  security.pam.enableSudoTouchIdAuth = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;

  environment.variables = {
    EDITOR = "nvim";
  };

  environment.shells = [
    pkgs.bashInteractive
  ];

  homebrew = {
    enable = true;
    casks = [
      "linearmouse"
    ];
  };

  services.skhd.enable = true;
  services.yabai = {
    enable = true;
    enableScriptingAddition = true;
    config = {
      layout = "bsp";
      focus_follows_mouse = "autofocus";
    };
  };

  programs.bash.completion.enable = true;

  users.users.gustas = {
    home = "/Users/gustas";
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = specialArgs;

    users.gustas = {
      programs.ssh = {
        enable = true;
        matchBlocks = {
	  "github.com".identityFile = "~/github";
          ${hidden.severas_domain}.identityFile = "~/.ssh/severas";
        };
      };

      home.packages = with pkgs; [
        deluge
	exiftool
        discord
        raycast
      ];
    };
  };
}
