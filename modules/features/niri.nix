_: {
  flake.nixosModules.niri = {
    pkgs,
    inputs,
    ...
  }: {
    imports = [
      inputs.niri.nixosModules.niri
    ];

    programs.niri.enable = true;
    programs.niri.package = inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.niri-unstable;
  };

  flake.homeModules.niriConfig = {pkgs, ...}: {
    home.packages = with pkgs; [
      xwayland-satellite
      playerctl
      brightnessctl
      pcmanfm
      vesktop
    ];

    programs.niri.settings = {
      screenshot-path = "~/screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

      layout = {
        gaps = 2;

        preset-column-widths = [
          {proportion = 0.5;}
          {proportion = 0.33333;}
          {proportion = 0.66666;}
        ];

        default-column-width = {
          proportion = 0.5;
        };

        struts = {
          left = 2;
          right = 2;
          top = 2;
          bottom = 2;
        };

        focus-ring = {
          width = 2.0;
          active.color = "#ffffff";
          inactive.color = "#555555";
        };
      };

      window-rules = [
        {
          geometry-corner-radius = {
            top-left = 10.0;
            top-right = 10.0;
            bottom-left = 10.0;
            bottom-right = 10.0;
          };

          clip-to-geometry = true;

          border = {
            enable = false;
          };
        }
      ];

      input = {
        mod-key = "Super";
        mod-key-nested = "Alt";

        focus-follows-mouse.enable = true;

        keyboard = {
          repeat-delay = 230;
          repeat-rate = 40;
        };
      };

      spawn-at-startup = [
        {command = ["noctalia"];}
      ];

      hotkey-overlay = {
        skip-at-startup = true;
      };

      binds = {
        # Keys consist of modifiers separated by + signs, followed by an XKB key name
        # in the end. To find an XKB name for a particular key, you may use a program
        # like wev.
        #
        # "Mod" is a special modifier equal to Super when running on a TTY, and to Alt
        # when running as a winit window.
        #
        # Most actions that you can bind here can also be invoked programmatically with
        # `niri msg action do-something`.

        # Mod-Shift-/, which is usually the same as Mod-?,
        # shows a list of important hotkeys.
        "Mod+Shift+Slash".action.show-hotkey-overlay = {};

        # Suggested binds for running programs: terminal, app launcher, screen locker.
        "Mod+T" = {
          hotkey-overlay.title = "Open a Terminal: ghostty";
          action.spawn = "ghostty";
        };
        "Mod+M" = {
          hotkey-overlay.title = "Open File Browser: pcmanfm";
          action.spawn = "pcmanfm";
        };
        "Mod+D" = {
          hotkey-overlay.title = "Open Noctalia launcher";
          action.spawn-sh = "noctalia msg panel-toggle launcher";
        };
        "Mod+I" = {
          hotkey-overlay.title = "Open a Browser: brave-origin";
          action.spawn = "brave-origin";
        };

        "Mod+Shift+D" = {
          hotkey-overlay.title = "Open Clipboard Manager";
          action.spawn-sh = "noctalia msg panel-toggle clipboard";
        };

        # Use spawn-sh to run a shell command. Do this if you need pipes, multiple commands, etc.
        # Note: the entire command goes as a single argument. It's passed verbatim to `sh -c`.
        # Example volume keys mappings for PipeWire & WirePlumber.
        # The allow-when-locked=true property makes them work even when the session is locked.
        # Using spawn-sh allows to pass multiple arguments together with the command.
        # "-l 1.0" limits the volume to 100%.
        "XF86AudioRaiseVolume" = {
          allow-when-locked = true;
          action.spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+ -l 1.0";
        };
        "XF86AudioLowerVolume" = {
          allow-when-locked = true;
          action.spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-";
        };
        "XF86AudioMute" = {
          allow-when-locked = true;
          action.spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        };
        "XF86AudioMicMute" = {
          allow-when-locked = true;
          action.spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
        };

        # Example media keys mapping using playerctl.
        # This will work with any MPRIS-enabled media player.
        "XF86AudioPlay" = {
          allow-when-locked = true;
          action.spawn-sh = "playerctl play-pause";
        };
        "XF86AudioPause" = {
          allow-when-locked = true;
          action.spawn-sh = "playerctl play-pause";
        };
        "XF86AudioStop" = {
          allow-when-locked = true;
          action.spawn-sh = "playerctl stop";
        };
        "XF86AudioPrev" = {
          allow-when-locked = true;
          action.spawn-sh = "playerctl previous";
        };
        "XF86AudioNext" = {
          allow-when-locked = true;
          action.spawn-sh = "playerctl next";
        };

        # Example brightness key mappings for brightnessctl.
        # You can use regular spawn with multiple arguments too (to avoid going through "sh"),
        # but you need to manually put each argument in separate "" quotes.
        "XF86MonBrightnessUp" = {
          allow-when-locked = true;
          action.spawn = ["brightnessctl" "--class=backlight" "set" "+10%"];
        };
        "XF86MonBrightnessDown" = {
          allow-when-locked = true;
          action.spawn = ["brightnessctl" "--class=backlight" "set" "10%-"];
        };

        # Open/close the Overview: a zoomed-out view of workspaces and windows.
        # You can also move the mouse into the top-left hot corner,
        # or do a four-finger swipe up on a touchpad.
        "Mod+O" = {
          repeat = false;
          action.toggle-overview = {};
        };

        "Mod+Q" = {
          repeat = false;
          action.close-window = {};
        };

        "Mod+Left".action.focus-column-or-monitor-left = {};
        "Mod+Down".action.focus-window-down = {};
        "Mod+Up".action.focus-window-up = {};
        "Mod+Right".action.focus-column-or-monitor-right = {};
        "Mod+H".action.focus-column-or-monitor-left = {};
        "Mod+J".action.focus-window-down = {};
        "Mod+K".action.focus-window-up = {};
        "Mod+L".action.focus-column-or-monitor-right = {};

        "Mod+Shift+Left".action.move-column-left = {};
        "Mod+Shift+Down".action.move-window-down = {};
        "Mod+Shift+Up".action.move-window-up = {};
        "Mod+Shift+Right".action.move-column-right = {};
        "Mod+Shift+H".action.move-column-left = {};
        "Mod+Shift+J".action.move-window-down = {};
        "Mod+Shift+K".action.move-window-up = {};
        "Mod+Shift+L".action.move-column-right = {};

        "Mod+Home".action.focus-column-first = {};
        "Mod+End".action.focus-column-last = {};
        "Mod+Ctrl+Home".action.move-column-to-first = {};
        "Mod+Ctrl+End".action.move-column-to-last = {};

        "Mod+Page_Down".action.focus-workspace-down = {};
        "Mod+Page_Up".action.focus-workspace-up = {};
        "Mod+N".action.focus-workspace-down = {};
        "Mod+P".action.focus-workspace-up = {};
        "Mod+Shift+Page_Down".action.move-column-to-workspace-down = {};
        "Mod+Shift+Page_Up".action.move-column-to-workspace-up = {};
        "Mod+Shift+N".action.move-column-to-workspace-down = {};
        "Mod+Shift+P".action.move-column-to-workspace-up = {};

        # Similarly, you can bind touchpad scroll "ticks".
        # Touchpad scrolling is continuous, so for these binds it is split into
        # discrete intervals.
        # These binds are also affected by touchpad's natural-scroll, so these
        # example binds are "inverted", since we have natural-scroll enabled for
        # touchpads by default.
        # "Mod+TouchpadScrollDown".action.spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.02+";
        # "Mod+TouchpadScrollUp".action.spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.02-";

        # You can refer to workspaces by index. However, keep in mind that
        # niri is a dynamic workspace system, so these commands are kind of
        # "best effort". Trying to refer to a workspace index bigger than
        # the current workspace count will instead refer to the bottommost
        # (empty) workspace.
        #
        # For example, with 2 workspaces + 1 empty, indices 3, 4, 5 and so on
        # will all refer to the 3rd workspace.
        "Mod+1".action.focus-workspace = 1;
        "Mod+2".action.focus-workspace = 2;
        "Mod+3".action.focus-workspace = 3;
        "Mod+4".action.focus-workspace = 4;
        "Mod+5".action.focus-workspace = 5;
        "Mod+6".action.focus-workspace = 6;
        "Mod+7".action.focus-workspace = 7;
        "Mod+8".action.focus-workspace = 8;
        "Mod+9".action.focus-workspace = 9;
        "Mod+Shift+1".action.move-column-to-workspace = 1;
        "Mod+Shift+2".action.move-column-to-workspace = 2;
        "Mod+Shift+3".action.move-column-to-workspace = 3;
        "Mod+Shift+4".action.move-column-to-workspace = 4;
        "Mod+Shift+5".action.move-column-to-workspace = 5;
        "Mod+Shift+6".action.move-column-to-workspace = 6;
        "Mod+Shift+7".action.move-column-to-workspace = 7;
        "Mod+Shift+8".action.move-column-to-workspace = 8;
        "Mod+Shift+9".action.move-column-to-workspace = 9;

        # Alternatively, there are commands to move just a single window:
        # "Mod+Ctrl+1".action.move-window-to-workspace = 1;

        # Switches focus between the current and the previous workspace.
        # "Mod+Tab".action.focus-workspace-previous = {};

        # The following binds move the focused window in and out of a column.
        # If the window is alone, they will consume it into the nearby column to the side.
        # If the window is already in a column, they will expel it out.
        # TODO: Find new binds for this
        # "Mod+BracketLeft".action.consume-or-expel-window-left = {};
        # "Mod+BracketRight".action.consume-or-expel-window-right = {};

        # Consume one window from the right to the bottom of the focused column.
        "Mod+Comma".action.consume-window-into-column = {};
        # Expel the bottom window from the focused column to the right.
        "Mod+Period".action.expel-window-from-column = {};

        # Cycle through widths set in preset-column-widths.
        "Mod+R".action.switch-preset-column-width = {};
        # Cycling through the presets in reverse order is also possible.
        "Mod+Shift+R".action.switch-preset-column-width-back = {};

        "Mod+Ctrl+Shift+R".action.switch-preset-window-height = {};
        "Mod+Ctrl+R".action.reset-window-height = {};

        "Mod+F".action.maximize-column = {};
        "Mod+Shift+F".action.fullscreen-window = {};

        # While maximize-column leaves gaps and borders around the window,
        # maximize-window-to-edges doesn't: the window expands to the edges of the screen.
        # This bind corresponds to normal window maximizing,
        # e.g. by double-clicking on the titlebar.
        # TODO:
        # "Mod+M".action.maximize-window-to-edges = {};

        # Expand the focused column to space not taken up by other fully visible columns.
        # Makes the column "fill the rest of the space".
        "Mod+Ctrl+F".action.expand-column-to-available-width = {};

        "Mod+C".action.center-column = {};

        # Center all fully visible columns on screen.
        "Mod+Ctrl+C".action.center-visible-columns = {};

        # Finer width adjustments.
        # This command can also:
        # * set width in pixels: "1000"
        # * adjust width in pixels: "-5" or "+5"
        # * set width as a percentage of screen width: "25%"
        # * adjust width as a percentage of screen width: "-10%" or "+10%"
        # Pixel sizes use logical, or scaled, pixels. I.e. on an output with scale 2.0,
        # set-column-width "100" will make the column occupy 200 physical screen pixels.
        "Mod+Minus".action.set-column-width = "-10%";
        "Mod+Equal".action.set-column-width = "+10%";

        # Finer height adjustments when in column with other windows.
        "Mod+Shift+Minus".action.set-window-height = "-10%";
        "Mod+Shift+Equal".action.set-window-height = "+10%";

        # Move the focused window between the floating and the tiling layout.
        "Mod+Space".action.toggle-window-floating = {};
        "Mod+Shift+Space".action.switch-focus-between-floating-and-tiling = {};

        # Toggle tabbed column display mode.
        # Windows in this column will appear as vertical tabs,
        # rather than stacked on top of each other.
        "Mod+W".action.toggle-column-tabbed-display = {};

        # Actions to switch layouts.
        # Note: if you uncomment these, make sure you do NOT have
        # a matching layout switch hotkey configured in xkb options above.
        # Having both at once on the same hotkey will break the switching,
        # since it will switch twice upon pressing the hotkey (once by xkb, once by niri).
        # "Mod+Space".action.switch-layout = "next";
        # "Mod+Shift+Space".action.switch-layout = "prev";

        "Print".action.screenshot = {};
        "Mod+Shift+S".action.screenshot = {};
        "Mod+S".action.screenshot-screen = {};

        # Applications such as remote-desktop clients and software KVM switches may
        # request that niri stops processing the keyboard shortcuts defined here
        # so they may, for example, forward the key presses as-is to a remote machine.
        # It's a good idea to bind an escape hatch to toggle the inhibitor,
        # so a buggy application can't hold your session hostage.
        #
        # The allow-inhibiting=false property can be applied to other binds as well,
        # which ensures niri always processes them, even when an inhibitor is active.
        "Mod+Escape" = {
          allow-inhibiting = false;
          action.toggle-keyboard-shortcuts-inhibit = {};
        };

        # The quit action will show a confirmation dialog to avoid accidental exits.
        "Mod+Shift+E".action.quit = {};
        "Ctrl+Alt+Delete".action.quit = {};
      };
    };
  };
}
