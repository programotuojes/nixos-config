{ pkgs, pkgs-unstable, firefox-addons, ... }:

{
  imports = [
    ./work.nix
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
    osu-lazer-bin
    parallel
    pkgs-unstable.insomnia
    pkgs-unstable.obsidian
    signal-desktop
    spotify
    sqlitebrowser
    telegram-desktop
    vlc
    wl-clipboard
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
        extensions = with firefox-addons; [
          ublock-origin
          bitwarden
          simple-tab-groups
          hover-zoom-plus
          sponsorblock
        ];
        settings = {
          "app.shield.optoutstudies.enabled" = false;
          "browser.contentblocking.category" = "strict";
          "browser.engagement.sidebar-button.has-used" = true;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
          "browser.startup.page" = 3;
          "browser.toolbars.bookmarks.visibility" = "newtab";
          "browser.uiCustomization.state" = {
            "placements" = {
              "widget-overflow-fixed-list" = [ ];
              "unified-extensions-area" = [
                "ublock0_raymondhill_net-browser-action"
                "_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action"
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
          "widget.use-xdg-desktop-portal.file-picker" = 1;
        };
      in
      {
        "Personal" = {
          id = 0;
          extensions = extensions;
          settings = settings;
          search.default = "DuckDuckGo";
          search.engines = engines;
          search.force = true;
        };
        "Work" = {
          id = 1;
          extensions = extensions;
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
}
