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

        nightlight = {
          enabled = true;
        };

        idle.behavior = {
          lock = {
            timeout = 600;
            action = "lock";
            enabled = true;
          };

          screen-off = {
            timeout = 660;
            action = "screen_off";
            enabled = true;
          };

          suspend = {
            timeout = 900;
            action = "lock_and_suspend";
            enabled = true;
          };
        };

        wallpaper = {
          enabled = true;

          directory = dfRoot + /pictures;

          default.path = dfRoot + /pictures/half-dome.jpg;
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

          start = ["workspaces" "media" "cpu" "ram"];
          center = ["clock"];
          end = [
            "gap"
            "tray"
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
