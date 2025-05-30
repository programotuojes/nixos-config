{ pkgs, ... }:

{
  users.users.jolanta = {
    isNormalUser = true;
    description = "Jolanta";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  home-manager.users.jolanta = {
    programs.home-manager.enable = true;
    home.username = "jolanta";
    home.homeDirectory = "/home/jolanta";
    home.stateVersion = "24.05";

    home.packages = with pkgs; [
      libreoffice
      vlc
      wl-clipboard
    ];

    programs.neovim = {
      enable = true;
      defaultEditor = true;
    };

    programs.git.enable = true;

    programs.firefox = {
      enable = true;
      profiles.Default = {
        id = 0;
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
              ];
              "nav-bar" = [
                "back-button"
                "forward-button"
                "stop-reload-button"
                "urlbar-container"
                "downloads-button"
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
            "currentVersion" = 20;
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
          "signon.rememberSignons" = true;
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
        search = {
          default = "DuckDuckGo";
          force = true;
          engines = {
            "Bing".metaData.hidden = true;
            "Amazon.com".metaData.hidden = true;
          };
        };
      };
    };
  };
}
