{...}: {
  flake.homeModules.yabai = {
    config,
    pkgs,
    lib,
    ...
  }: let
    isDarwin = pkgs.stdenv.hostPlatform.isDarwin;

    yabaiConfig = pkgs.writeShellScript "yabairc" ''
      # Load the scripting addition after Dock restarts.
      ${pkgs.yabai}/bin/yabai -m signal --add \
        event=dock_did_restart \
        action="sudo ${pkgs.yabai}/bin/yabai --load-sa"

      sudo ${pkgs.yabai}/bin/yabai --load-sa

      ${pkgs.yabai}/bin/yabai -m config \
        mouse_follows_focus          off \
        focus_follows_mouse          off \
        window_origin_display        default \
        window_zoom_persist          on \
        window_topmost               off \
        window_shadow                on \
        window_animation_duration    0.0 \
        window_animation_frame_rate  120 \
        window_opacity_duration      0.0 \
        active_window_opacity        1.0 \
        normal_window_opacity        0.90 \
        window_opacity               off \
        insert_feedback_color        0xffd75f5f \
        active_window_border_color   0xff775759 \
        normal_window_border_color   0xff555555 \
        window_border_width          4 \
        window_border_radius         12 \
        window_border_blur           off \
        window_border_hidpi          on \
        window_border                off \
        split_ratio                  0.50 \
        split_type                   auto \
        auto_balance                 off \
        top_padding                  10 \
        bottom_padding               10 \
        left_padding                 10 \
        right_padding                10 \
        window_gap                   10 \
        layout                       bsp \
        mouse_modifier               fn \
        mouse_action1                move \
        mouse_action2                resize \
        mouse_drop_action            swap

      # Unmanaged / floating applications.
      ${pkgs.yabai}/bin/yabai -m rule --add \
        app="^Disk Utility$" sticky=on layer=above manage=off

      ${pkgs.yabai}/bin/yabai -m rule --add \
        app="^FaceTime$" sticky=on layer=above manage=off

      ${pkgs.yabai}/bin/yabai -m rule --add \
        app="^System Settings$" sticky=on manage=off

      ${pkgs.yabai}/bin/yabai -m rule --add \
        app="^Stats$" sticky=on manage=off

      ${pkgs.yabai}/bin/yabai -m rule --add \
        app="^Calculator$" sticky=on manage=off

      ${pkgs.yabai}/bin/yabai -m rule --add \
        app="^Finder$" sticky=on manage=off

      ${pkgs.yabai}/bin/yabai -m rule --add \
        app="^System Information$" sticky=on manage=off

      ${pkgs.yabai}/bin/yabai -m rule --add \
        app="^Activity Monitor$" sticky=on manage=off

      ${pkgs.yabai}/bin/yabai -m rule --add \
        app="^Console$" manage=off

      ${pkgs.yabai}/bin/yabai -m rule --add \
        app="^Digital Colou?r Meter$" sticky=on manage=off

      ${pkgs.yabai}/bin/yabai -m rule --add \
        app="^Pomotroid$" manage=off

      ${pkgs.yabai}/bin/yabai -m rule --add \
        app="^Anki$" opacity=0.90

      ${pkgs.yabai}/bin/yabai -m rule --add \
        app="^OpenVPN Connect$" manage=off

      echo "yabai configuration loaded"
    '';

    skhdConfig = pkgs.writeText "skhdrc" ''
      # Restart Home Manager-managed yabai.
      ctrl + alt + cmd - r : launchctl kickstart -k "gui/''${UID}/org.nix-community.home.yabai"

      # Focus window.
      alt - h : ${pkgs.yabai}/bin/yabai -m window --focus west
      alt - j : ${pkgs.yabai}/bin/yabai -m window --focus south
      alt - k : ${pkgs.yabai}/bin/yabai -m window --focus north
      alt - l : ${pkgs.yabai}/bin/yabai -m window --focus east

      # Move managed window.
      shift + alt - h : ${pkgs.yabai}/bin/yabai -m window --warp west
      shift + alt - j : ${pkgs.yabai}/bin/yabai -m window --warp south
      shift + alt - k : ${pkgs.yabai}/bin/yabai -m window --warp north
      shift + alt - l : ${pkgs.yabai}/bin/yabai -m window --warp east

      # Balance windows.
      shift + alt - 0 : ${pkgs.yabai}/bin/yabai -m space --balance

      # Rotate layout.
      alt - r         : ${pkgs.yabai}/bin/yabai -m space --rotate 90
      shift + alt - r : ${pkgs.yabai}/bin/yabai -m space --rotate 270

      # Move window to space and follow it.
      shift + alt - 1 : ${pkgs.yabai}/bin/yabai -m window --space 1; ${pkgs.yabai}/bin/yabai -m space --focus 1
      shift + alt - 2 : ${pkgs.yabai}/bin/yabai -m window --space 2; ${pkgs.yabai}/bin/yabai -m space --focus 2
      shift + alt - 3 : ${pkgs.yabai}/bin/yabai -m window --space 3; ${pkgs.yabai}/bin/yabai -m space --focus 3
      shift + alt - 4 : ${pkgs.yabai}/bin/yabai -m window --space 4; ${pkgs.yabai}/bin/yabai -m space --focus 4
      shift + alt - 5 : ${pkgs.yabai}/bin/yabai -m window --space 5; ${pkgs.yabai}/bin/yabai -m space --focus 5
      shift + alt - 6 : ${pkgs.yabai}/bin/yabai -m window --space 6; ${pkgs.yabai}/bin/yabai -m space --focus 6
      shift + alt - 7 : ${pkgs.yabai}/bin/yabai -m window --space 7; ${pkgs.yabai}/bin/yabai -m space --focus 7
      shift + alt - 8 : ${pkgs.yabai}/bin/yabai -m window --space 8; ${pkgs.yabai}/bin/yabai -m space --focus 8
      shift + alt - 9 : ${pkgs.yabai}/bin/yabai -m window --space 9; ${pkgs.yabai}/bin/yabai -m space --focus 9

      # Float / unfloat.
      shift + alt - space : ${pkgs.yabai}/bin/yabai -m window --toggle float

      # Stack navigation.
      alt - n : ${pkgs.yabai}/bin/yabai -m window --focus stack.next
      alt - p : ${pkgs.yabai}/bin/yabai -m window --focus stack.prev

      # Move floating window.
      shift + ctrl - a : ${pkgs.yabai}/bin/yabai -m window --move rel:-20:0
      shift + ctrl - s : ${pkgs.yabai}/bin/yabai -m window --move rel:0:20

      # Increase window size.
      shift + alt - a : ${pkgs.yabai}/bin/yabai -m window --resize left:-20:0
      shift + alt - w : ${pkgs.yabai}/bin/yabai -m window --resize top:0:-20

      # Decrease window size.
      shift + alt - d : ${pkgs.yabai}/bin/yabai -m window --resize right:20:0
      shift + alt - s : ${pkgs.yabai}/bin/yabai -m window --resize top:0:20

      # Set insertion point.
      ctrl + alt - h : ${pkgs.yabai}/bin/yabai -m window --insert west

      # Zoom focused window.
      alt - f : ${pkgs.yabai}/bin/yabai -m window --toggle zoom-fullscreen

      # Toggle split direction.
      alt - e : ${pkgs.yabai}/bin/yabai -m window --toggle split

      # Launch terminal.
      shift + alt - return : open -na "Ghostty"
    '';
  in {
    config = lib.mkIf isDarwin {
      home.packages = with pkgs; [
        yabai
        skhd
      ];

      home.file.".config/yabai/yabairc" = {
        source = yabaiConfig;
        executable = true;
      };

      home.file.".config/skhd/skhdrc".source = skhdConfig;

      launchd.agents.yabai = {
        enable = true;

        config = {
          ProgramArguments = [
            "${pkgs.yabai}/bin/yabai"
            "-c"
            "${config.home.homeDirectory}/.config/yabai/yabairc"
          ];

          RunAtLoad = true;
          KeepAlive = true;
          ProcessType = "Interactive";

          StandardOutPath = "${config.home.homeDirectory}/Library/Logs/yabai.log";

          StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/yabai.error.log";

          EnvironmentVariables = {
            PATH =
              lib.makeBinPath [
                pkgs.yabai
                pkgs.coreutils
              ]
              + ":/usr/bin:/bin:/usr/sbin:/sbin";
          };
        };
      };

      launchd.agents.skhd = {
        enable = true;

        config = {
          ProgramArguments = [
            "${pkgs.skhd}/bin/skhd"
            "-c"
            "${config.home.homeDirectory}/.config/skhd/skhdrc"
          ];

          RunAtLoad = true;
          KeepAlive = true;
          ProcessType = "Interactive";

          StandardOutPath = "${config.home.homeDirectory}/Library/Logs/skhd.log";

          StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/skhd.error.log";

          EnvironmentVariables = {
            PATH =
              lib.makeBinPath [
                pkgs.yabai
                pkgs.skhd
              ]
              + ":/usr/bin:/bin:/usr/sbin:/sbin";
          };
        };
      };
    };
  };
}
