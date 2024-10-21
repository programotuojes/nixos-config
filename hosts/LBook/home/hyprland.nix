{ pkgs, config, ... }:

{
  home.packages = with pkgs; [
    grim
    slurp
    hyprpicker
    hyprland-per-window-layout
    pavucontrol
    networkmanagerapplet
  ];

  stylix.targets.tofi.enable = false;
  programs.tofi = {
    enable = true;
    settings = {
      width = "100%";
      height = "100%";
      border-width = 0;
      outline-width = 0;
      padding-left = "35%";
      padding-top = "35%";
      result-spacing = 25;
      num-results = 5;
      font = "monospace";
      background-color = "#000A";
    };
  };

  programs.wlogout = {
    enable = true;
    layout = [
      {
        label = "lock";
        action = "hyprlock";
        text = "Lock";
        keybind = "l";
      }
      {
        label = "hibernate";
        action = "systemctl hibernate";
        text = "Hibernate";
        keybind = "h";
      }
      {
        label = "logout";
        action = "hyprctl dispatch exit 1";
        text = "Logout";
        keybind = "e";
      }
      {
        label = "shutdown";
        action = "systemctl poweroff";
        text = "Shutdown";
        keybind = "s";
      }
      {
        label = "suspend";
        action = "systemctl suspend";
        text = "Suspend";
        keybind = "u";
      }
      {
        label = "reboot";
        action = "systemctl reboot";
        text = "Reboot";
        keybind = "r";
      }
    ];
  };

  stylix.targets.mako.enable = false;
  services.mako = with config.lib.stylix.colors.withHashtag; {
    enable = true;
    defaultTimeout = 5000;

    borderSize = 2;
    borderRadius = 8;
    borderColor = base07;

    progressColor = "over ${base02}";
    backgroundColor = base00;

    textColor = base07;

    extraConfig = ''
      [urgency=low]
      border-color=${base04}

      [urgency=normal]
      border-color=${base07}

      [urgency=high]
      border-color=${base08}
      default-timeout=0
    '';
  };
}
