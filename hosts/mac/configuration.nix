{ pkgs, inputs, specialArgs, hidden, config, ... }:

{
  imports = [
    ../../users/gustas.nix
    ./sketchybar
    ./work.nix
    inputs.home-manager.darwinModules.default
  ];

  nix.settings.experimental-features = "nix-command flakes";

  nixpkgs = {
    hostPlatform = "aarch64-darwin";
    config.allowUnfree = true;
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  power.sleep = {
    allowSleepByPowerButton = true;
    display = 10;
    harddisk = 11;
    computer = 15;
  };

  fonts.packages = with pkgs; [
    nerd-fonts.hack
    jetbrains-mono
  ];

  system = {
    # Used for backwards compatibility, please read the changelog before changing.
    # $ darwin-rebuild changelog
    stateVersion = 5;
    primaryUser = "gustas";
    defaults = {
      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        ApplePressAndHoldEnabled = false;
        InitialKeyRepeat = 15;
        KeyRepeat = 3;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticInlinePredictionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        _HIHideMenuBar = true;
        "com.apple.keyboard.fnState" = true;
      };
      dock = {
        autohide = true;
        autohide-delay = 0.0;
        autohide-time-modifier = 0.4;
        mru-spaces = false;
        tilesize = 50;
        wvous-bl-corner = 1;
        wvous-br-corner = 1;
        wvous-tl-corner = 2;
        wvous-tr-corner = 12;
      };
      finder = {
        AppleShowAllExtensions = true;
        FXEnableExtensionChangeWarning = false;
        NewWindowTarget = "Home";
        ShowPathbar = true;
      };
      hitoolbox.AppleFnUsageType = "Change Input Source";
      screencapture.target = "clipboard";
      spaces.spans-displays = false;
      WindowManager.EnableStandardClickToShowDesktop = false;
      trackpad.Clicking = true;
    };
    startup.chime = false;
  };

  environment = {
    shells = [ pkgs.bashInteractive ];
    variables = {
      EDITOR = "nvim";
      HOMEBREW_NO_ANALYTICS = "1";
    };
  };

  system.activationScripts.postActivation.text = ''
    su - "$(logname)" -c '${config.services.skhd.package}/bin/skhd -r'
  '';

  services.skhd = {
    enable = true;
    skhdConfig = ''
      cmd + alt - t : /etc/profiles/per-user/gustas/bin/kitty --single-instance -d ~
    '';
  };

  services.yabai = {
    enable = true;
    enableScriptingAddition = true;
    config = {
      layout = "bsp";
      focus_follows_mouse = "autofocus";
      window_gap = 10;
      top_padding = 10;
      bottom_padding = 10;
      left_padding = 10;
      right_padding = 10;
      external_bar = "all:40:0";
    };
  };

  programs.bash.completion.enable = true;

  users.users.gustas.home = "/Users/gustas";

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = specialArgs;
    backupFileExtension = "bak";

    users.gustas = {
      programs.ssh = {
        enable = true;
        matchBlocks = {
          "*".setEnv.TERM = "xterm-256color";
          ${hidden.severas_domain}.identityFile = "~/.ssh/severas";
        };
      };

      programs.bash = {
        bashrcExtra = ''
          eval "$(/opt/homebrew/bin/brew shellenv)"
        '';
      };

      home.packages = with pkgs; [
        coreutils
        exiftool
        raycast
        wireguard-tools
        yt-dlp
        zulu
      ];

      programs.librewolf = {
        enable = true;
        settings = {
          "webgl.disabled" = false;
          "privacy.clearOnShutdown.history" = false;
          "privacy.resistFingerprinting" = false;
          "privacy.fingerprintingProtection" = true;
          "privacy.fingerprintingProtection.overrides" = "+AllTargets,-CSSPrefersColorScheme,-JSDateTimeUTC";
        };
      };

      programs.kitty = {
        enable = true;

        enableGitIntegration = true;
        shellIntegration.enableBashIntegration = true;

        font = {
          size = 13;
          name = "JetBrains Mono";
        };

        settings = {
          disable_ligatures = "cursor";
          text_composition_strategy = "legacy"; # Fixes the weird look
          modify_font = "cell_height 110%";
          window_padding_width = 8;
          window_border_width = 0;
          macos_titlebar_color = "background";
          placement_strategy = "top";

          include = "testing.conf";
        };
      };
    };
  };
}
