{ inputs, pkgs, config, hidden, ... }:

{
  nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];
  environment.defaultPackages = [ pkgs.tmux ];
  users.groups.${config.services.minecraft-servers.group}.members = [
    "gustas"
  ];

  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = true;
    servers.klevas = {
      enable = true;
      enableReload = true;
      package = pkgs.paperServers.paper-1_21_5;
      jvmOpts = "-Xms6G -Xmx6G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true";
      serverProperties = {
        difficulty = "hard";
        enforce-whitelist = true;
        max-players = 30;
        motd = "Skanaus";
        server-port = hidden.minecraft.port;
        spawn-protection = 0;
        white-list = true;
      };
    };
  };
}
