{ pkgs, pkgs-unstable, ... }:

{
  hardware.opengl.enable = true;

  programs.hyprland.enable = true;
  programs.hyprland.package = pkgs-unstable.hyprland;

  programs.hyprlock.enable = true;
  programs.hyprlock.package = pkgs-unstable.hyprlock.overrideAttrs (oldAttrs: {
    # https://github.com/hyprwm/hyprlock/issues/128
    patchPhase = ''
      substituteInPlace src/core/hyprlock.cpp --replace "5000" "16"
    '';
  });

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  environment.systemPackages = with pkgs; [
    pkgs-unstable.waybar
    hyprpaper
  ];

  security.pam.services.hyprlock = { };
}
