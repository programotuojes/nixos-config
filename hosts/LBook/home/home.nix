{ pkgs, pkgs-unstable, inputs, config, ... }:

{
  imports = [
    ./work.nix
    ./hyprland.nix
    inputs.spicetify-nix.homeManagerModules.default
  ];

  home.username = "gustas";
  home.homeDirectory = "/home/gustas";
  home.stateVersion = "23.11";
  programs.home-manager.enable = true;

  home.shellAliases = {
    grep = "grep --color=auto";
    ip = "ip --color=auto";
  };

  programs.bash = {
    enable = true;
    bashrcExtra = ''
      eval "$(zoxide init bash)"
    '';
  };

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "ssh.dev.azure.com".identityFile = "~/.ssh/azure-devops";
      "github.com".identityFile = "~/.ssh/github";
      "klevas.org" = {
        identityFile = "~/.ssh/severas";
        user = "root";
      };
    };
  };

  programs.git = {
    enable = true;
    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
    };
    aliases.sw = "switch";
    includes =
      [
        {
          condition = "gitdir:~/";
          contents.user = {
            email = "programotuojes@users.noreply.github.com";
            name = "Gustas Klevinskas";
          };
        }
        {
          condition = "gitdir:~/bentley/";
          contents = {
            user = {
              email = "gustas.klevinskas@bentley.com";
              name = "Gustas Klevinskas";
            };
          };
        }
      ];
  };

  programs.readline = {
    enable = true;
    extraConfig = ''
      set completion-ignore-case on
    '';
  };

  home.packages = with pkgs; [
    anki
    appimage-run
    burpsuite
    deluge
    discord
    gimp
    git-crypt
    jdk
    jellyfin-media-player
    jq
    kate
    libreoffice
    libsForQt5.yakuake
    nextcloud-client
    nh
    nixpkgs-fmt
    openfortivpn
    pkgs-unstable.osu-lazer-bin
    parallel
    pkgs-unstable.insomnia
    pkgs-unstable.obsidian
    signal-desktop
    # spotify
    sqlitebrowser
    telegram-desktop
    vlc
    wl-clipboard
    xdg-utils
    zoxide

    # Neovim stuff
    cargo
    gcc
    ripgrep
    unzip
  ];

  programs.firefox = {
    enable = true;

    profiles =
      let
        engines = {
          "Nix Packages" = {
            urls = [{
              template = "https://search.nixos.org/packages";
              params = [
                { name = "type"; value = "packages"; }
                { name = "query"; value = "{searchTerms}"; }
              ];
            }];

            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@np" ];
          };
          "Nix Options" = {
            urls = [{
              template = "https://search.nixos.org/options";
              params = [
                { name = "type"; value = "options"; }
                { name = "query"; value = "{searchTerms}"; }
              ];
            }];

            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@no" ];
          };
          "Bing".metaData.hidden = true;
          "Amazon.com".metaData.hidden = true;
        };
        settings = {
          "app.normandy.enabled" = false;
          "app.shield.optoutstudies.enabled" = false;
          "browser.contentblocking.category" = "strict";
          "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;
          "browser.discovery.enabled" = false;
          "browser.engagement.sidebar-button.has-used" = true;
          "browser.newtabpage.activity-stream.feeds.telemetry" = false;
          "browser.newtabpage.activity-stream.showSponsored" = false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
          "browser.newtabpage.activity-stream.telemetry" = false;
          "browser.startup.page" = 3;
          "browser.tabs.crashReporting.sendReport" = false;
          "browser.toolbars.bookmarks.visibility" = "newtab";
          "browser.uiCustomization.state" = {
            "placements" = {
              "widget-overflow-fixed-list" = [ ];
              "unified-extensions-area" = [
                "ublock0_raymondhill_net-browser-action"
                "sponsorblocker_ajay_app-browser-action"
              ];
              "nav-bar" = [
                "back-button"
                "forward-button"
                "stop-reload-button"
                "urlbar-container"
                "downloads-button"
                "simple-tab-groups_drive4ik-browser-action"
                "sidebar-button"
                "unified-extensions-button"
              ];
              "toolbar-menubar" = [
                "menubar-items"
              ];
              "TabsToolbar" = [
                "tabbrowser-tabs"
                "new-tab-button"
                "alltabs-button"
              ];
              "PersonalToolbar" = [
                "personal-bookmarks"
              ];
            };
            "seen" = [
              "save-to-pocket-button"
              "developer-button"
            ];
            "dirtyAreaCache" = [
              "nav-bar"
              "PersonalToolbar"
              "toolbar-menubar"
              "TabsToolbar"
            ];
            "currentVersion" = 19;
            "newElementCount" = 4;
          };
          "browser.warnOnQuitShortcut" = true;
          "datareporting.healthreport.uploadEnabled" = false;
          "datareporting.policy.dataSubmissionEnabled" = false;
          "extensions.htmlaboutaddons.recommendations.enabled" = false;
          "extensions.pocket.enabled" = false;
          "geo.provider.use_geoclue" = false;
          "media.eme.enabled" = true;
          "network.http.referer.disallowCrossSiteRelaxingDefault.top_navigation" = true;
          "privacy.annotate_channels.strict_list.enabled" = true;
          "privacy.donottrackheader.enabled" = true;
          "privacy.partition.network_state.ocsp_cache" = true;
          "privacy.query_stripping.enabled" = true;
          "privacy.query_stripping.enabled.pbmode" = true;
          "privacy.trackingprotection.emailtracking.enabled" = true;
          "privacy.trackingprotection.enabled" = true;
          "privacy.trackingprotection.socialtracking.enabled" = true;
          "sidebar.position_start" = false;
          "signon.autofillForms.http" = true;
          "signon.management.page.breach-alerts.enabled" = false;
          "signon.rememberSignons" = false;
          "toolkit.coverage.opt-out" = true;
          "toolkit.telemetry.archive.enabled" = false;
          "toolkit.telemetry.bhrPing.enabled" = false;
          "toolkit.telemetry.coverage.opt-out" = true;
          "toolkit.telemetry.enabled" = false;
          "toolkit.telemetry.firstShutdownPing.enabled" = false;
          "toolkit.telemetry.newProfilePing.enabled" = false;
          "toolkit.telemetry.shutdownPingSender.enabled" = false;
          "toolkit.telemetry.unified" = false;
          "toolkit.telemetry.updatePing.enabled" = false;
          "widget.use-xdg-desktop-portal.file-picker" = 1;
        };
      in
      {
        "Personal" = {
          id = 0;
          settings = settings;
          search.default = "DuckDuckGo";
          search.engines = engines;
          search.force = true;
        };
        "Work" = {
          id = 1;
          settings = settings // {
            "signon.rememberSignons" = true;
            "browser.toolbars.bookmarks.visibility" = "always";
          };
          search.default = "DuckDuckGo";
          search.engines = engines;
          search.force = true;
        };
      };
  };

  programs.kitty.enable = true;
  programs.spicetify = {
    enable = true;
    theme = {
      name = "stylix";
      src = pkgs.writeTextFile {
        name = "color.ini";
        destination = "/color.ini";
        text = with config.lib.stylix.colors; ''
          [base]
          text               = ${base07}
          subtext            = ${base06}
          main               = ${base00}
          main-elevated      = ${base02}
          highlight          = ${base02}
          highlight-elevated = ${base03}
          sidebar            = ${base01}
          player             = ${base05}
          card               = ${base02}
          shadow             = ${base00}
          selected-row       = ${base05}
          button             = ${base05}
          button-active      = ${base05}
          button-disabled    = ${base03}
          radio-btn-active   = ${base05}
          tab-active         = ${base02}
          notification       = ${base02}
          notification-error = ${base08}
          equalizer          = ${base0B}
          misc               = ${base02}
        '';
      };
      # Sidebar configuration is incompatible with the default navigation bar
      sidebarConfig = false;
    };
    colorScheme = "base";
  };
}
