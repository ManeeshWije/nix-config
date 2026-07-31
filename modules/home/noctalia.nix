{self, ...}: {
  flake.homeModules.noctalia = {
    pkgs,
    inputs,
    dfRoot,
    ...
  }: {
    imports = [
      inputs.noctalia.homeModules.default
    ];

    programs.noctalia = {
      enable = true;
      
      settings = {
        theme = {
          mode = "dark";
          source = "wallpaper";
          wallpaper_scheme = "m3-content";
        };

        wallpaper = {
          directory = dfRoot + /pictures/yosemite.jpg;
        };

        widget.gap = {
          type = "spacer";
          length = 40;
        };

        widget.cpu = {
          type = "sysmon";
          stat = "cpu_usage";
          display = "graph";
        };
        widget.ram = {
          type = "sysmon";
          stat = "ram_used";
          display = "graph";
        };
        widget.gpu = {
          type = "sysmon";
          stat = "gpu_vram";
          display = "graph";
        };

        widget.workspaces = {
          display = "name";
          hide_when_empty = true;
        };

        bar.default = {
          margin_edge = 0;
          margin_ends = 0;
          radius = 0;
          shadow = false;
          capsule = true;

          start = ["workspaces"];
          center = ["clock"];
          end = [
            "media"
            "tray"
            "gap"
            "cpu"
            "ram"
            "gpu"
            "gap"
            "screenshot"
            "clipboard"
            "network"
            "battery"
            "bluetooth"
            "volume"
            "brightness"
            "notifications"
          ];
        };

        location.auto_locate = true;
        shell.telemetry_enabled = false;

        dock = {
          enabled = true;
          auto_hide = true;
          reserve_space = false;
        };

        system.monitor = {
          gpu_poll_seconds = 5.0;
        };
      };
    };
  };
}
