{ pkgs, ... }:

{
  users.users.git = {
    isSystemUser = true;
    group = "git";
    home = "/pool/git";
    createHome = true;
    shell = "${pkgs.git}/bin/git-shell";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO+gwgHsuoQ7bWMYJQ+F5CZgjFvdBNZ3eEAlmZ9rmk3R gustas@LBook"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAkqnik4bo2t3eVaQtaAaPHLBjVv53nrUYf7B15W3B6u r5800x3d@DESKTOP-V85LMH7"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAYn8UTA0jhrwOezoVHJAgO6FLNvzuIrczAMumUkgSJh thecheesy0ne@sauliusOMEN"
    ];
  };

  users.groups.git = {};

  services.openssh = {
    enable = true;
    extraConfig = ''
      Match user git
        AllowTcpForwarding no
        AllowAgentForwarding no
        PasswordAuthentication no
        PermitTTY no
        X11Forwarding no
    '';
  };
}
