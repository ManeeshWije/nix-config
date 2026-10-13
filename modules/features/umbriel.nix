{inputs, ...}: {
  flake.nixosModules.umbriel = {...}: {
    imports = [
      inputs.umbriel.nixosModules.default
    ];

    programs.umbriel.enable = true;

    nix.settings = {
      extra-substituters = ["https://umbriel.cachix.org"];
      extra-trusted-public-keys = [
        "umbriel.cachix.org-1:JfNq/2yg2S6D6z4Z2dVSZrZlDPQTKtexB6GAVLD98nw="
      ];
    };
  };

  flake.homeModules.umbrielConfig = {pkgs, ...}: {
    imports = [
      inputs.umbriel.homeModules.default
    ];

    home.packages = with pkgs; [
      playerctl
      brightnessctl
      wl-clipboard
      pcmanfm
      vesktop
      localsend
      proton-authenticator
      proton-vpn
      onlyoffice-desktopeditors
      obs-studio
      gimp
      jellyfin-desktop
    ];

    home.pointerCursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 24;
      gtk.enable = true;
      x11.enable = true;
    };

    programs.umbriel = {
      enable = true;

      settings = {
        general = {
          mod_key = "Alt";
          autostart = ["noctalia"];
          show_cheatsheet = false;
        };

        output."eDP-1" = {
          scale = 1.0;
          workspace_axis = "vertical";
          workspaces = "dynamic";
          focus_at_startup = true;
        };

        input = {
          keyboard = {
            repeat_delay = 230;
            repeat_rate = 40;
            options = "caps:ctrl_modifier";
          };

          touchpad = {
            natural_scroll = true;
            tap = true;
          };

          mouse = {
            natural_scroll = false;
          };

          focus.follows_mouse = true;

          cursor = {
            theme = "Bibata-Modern-Ice";
            size = 24;
          };
        };

        layout = {
          mode = "dwindle";
          gap = 4;
          struts = {
            left = 2;
            right = 2;
            top = 2;
            bottom = 2;
          };
        };

        appearance = {
          border_width = 2;
          corner_radius = 10;
          tab_bar.hide_when_single = true;
        };

        colors.border = {
          focused = "#FFFFFFFF";
          unfocused = "#555555FF";
        };

        window_rule = [
          {
            border_width = 2;
            corner_radius = 10;
          }
        ];

        keybinds = {
          # Applications / launcher
          "Mod+T" = "spawn:ghostty";
          "Mod+M" = "spawn:pcmanfm";
          "Mod+D" = "spawn:noctalia msg panel-toggle launcher";
          "Mod+I" = "spawn:firefox-devedition";
          "Mod+Shift+D" = "spawn:noctalia msg panel-toggle clipboard";
          "Mod+Shift+Slash" = "cheatsheet-toggle";

          # Volume
          "XF86AudioRaiseVolume" = {
            action = "spawn:wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+ -l 1.0";
            allow_when_locked = true;
          };
          "XF86AudioLowerVolume" = {
            action = "spawn:wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-";
            allow_when_locked = true;
          };
          "XF86AudioMute" = {
            action = "spawn:wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
            allow_when_locked = true;
          };
          "XF86AudioMicMute" = {
            action = "spawn:wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
            allow_when_locked = true;
          };

          # Media controls
          "XF86AudioPlay" = "spawn:playerctl play-pause";
          "XF86AudioPause" = "spawn:playerctl play-pause";
          "XF86AudioStop" = "spawn:playerctl stop";
          "XF86AudioPrev" = "spawn:playerctl previous";
          "XF86AudioNext" = "spawn:playerctl next";

          # Brightness
          "XF86MonBrightnessUp" = {
            action = "spawn:brightnessctl --class=backlight set +10%";
            allow_when_locked = true;
          };
          "XF86MonBrightnessDown" = {
            action = "spawn:brightnessctl --class=backlight set 10%-";
            allow_when_locked = true;
          };

          # Overview / window management
          "Mod+O" = "overview-toggle";
          "Mod+Q" = {
            action = "window-close";
            repeat = false;
          };

          # Focus (arrows and Vim keys)
          "Mod+Left" = "window-focus-or-output-left";
          "Mod+Down" = "window-focus-down";
          "Mod+Up" = "window-focus-up";
          "Mod+Right" = "window-focus-or-output-right";
          "Mod+H" = "window-focus-or-output-left";
          "Mod+J" = "window-focus-down";
          "Mod+K" = "window-focus-up";
          "Mod+L" = "window-focus-or-output-right";

          # Swap tiled windows in dwindle layout
          "Mod+Shift+Left" = "window-swap-left";
          "Mod+Shift+Down" = "window-swap-down";
          "Mod+Shift+Up" = "window-swap-up";
          "Mod+Shift+Right" = "window-swap-right";
          "Mod+Shift+H" = "window-swap-left";
          "Mod+Shift+J" = "window-swap-down";
          "Mod+Shift+K" = "window-swap-up";
          "Mod+Shift+L" = "window-swap-right";

          # Workspace navigation
          "Mod+Page_Down" = "workspace-next";
          "Mod+Page_Up" = "workspace-previous";
          "Mod+N" = "workspace-next";
          "Mod+P" = "workspace-previous";

          # Workspaces 1-9
          "Mod+1" = "workspace-switch:1";
          "Mod+2" = "workspace-switch:2";
          "Mod+3" = "workspace-switch:3";
          "Mod+4" = "workspace-switch:4";
          "Mod+5" = "workspace-switch:5";
          "Mod+6" = "workspace-switch:6";
          "Mod+7" = "workspace-switch:7";
          "Mod+8" = "workspace-switch:8";
          "Mod+9" = "workspace-switch:9";

          # Move window to workspace 1-9
          "Mod+Shift+1" = "window-move-to-workspace:1";
          "Mod+Shift+2" = "window-move-to-workspace:2";
          "Mod+Shift+3" = "window-move-to-workspace:3";
          "Mod+Shift+4" = "window-move-to-workspace:4";
          "Mod+Shift+5" = "window-move-to-workspace:5";
          "Mod+Shift+6" = "window-move-to-workspace:6";
          "Mod+Shift+7" = "window-move-to-workspace:7";
          "Mod+Shift+8" = "window-move-to-workspace:8";
          "Mod+Shift+9" = "window-move-to-workspace:9";

          # Maximize / fullscreen
          "Mod+F" = "window-toggle-maximize";
          "Mod+Shift+F" = "window-toggle-fullscreen";

          # Floating windows
          "Mod+Space" = "window-toggle-floating";
          "Mod+Shift+Space" = "window-focus-switch-floating";

          # Screenshots via Noctalia
          "Print" = "spawn:noctalia msg screenshot-region";
          "Mod+Shift+S" = "spawn:noctalia msg screenshot-region";
          "Mod+S" = "spawn:noctalia msg screenshot-fullscreen";

          # Keyboard shortcut inhibition
          "Mod+Escape" = {
            action = "shortcuts-inhibit-toggle";
            allow_when_inhibited = true;
            repeat = false;
          };

          # Session / reload
          "Mod+Shift+E" = "session-quit";
          "Ctrl+Alt+Delete" = "session-quit";
          "Mod+Ctrl+Shift+C" = "config-reload";
        };
      };
    };
  };
}
