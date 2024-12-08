{ pkgs, ... }:

let
  user = "gustas";
in
{
  hardware.opengl.enable = true;

  programs.hyprland.enable = true;

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];


  home-manager.users.${user} = {
    home.packages = with pkgs; [
      grim
      hyprland-per-window-layout
      hyprpicker
      networkmanagerapplet
      pavucontrol
      slurp
      waybar
    ];

    programs.kitty.enable = true;

    services.hyprpaper = {
      enable = true;
      settings = {
        preload = [ "/home/${user}/Pictures/Wallpapers/pandas.jpg" ];
        wallpaper = [ ",/home/${user}/Pictures/Wallpapers/pandas.jpg" ];
      };
    };

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

    services.mako = {
      enable = true;
      defaultTimeout = 5000;
      borderSize = 2;
      borderRadius = 8;
    };
  };
}
