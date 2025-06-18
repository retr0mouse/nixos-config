{ config, pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;

    extraConfig = ''
      $terminal = kitty
      $fileManager = dolphin
      $menu = wofi --show drun
      $browser = firefox
      
      # Config for the displays
      source = ~/.config/hypr/monitors.conf

      # Autostart apps
      exec-once = hyprpanel &
      
      # Disablee ALL animations
      animations {
        enabled = 0
      }

      misc {
        disable_hyprland_logo = true
	disable_splash_rendering = true
      }

      # Input config
      input {
        kb_layout = ee(us), ru
	kb_options = grp:ctrl_space_toggle
        follow_mouse = 2

        touchpad {
          natural_scroll = yes
	  disable_while_typing = true
        }
      }

      # General settings
      general {
        gaps_in = 0
        gaps_out = 0
        border_size = 0
        layout = dwindle
	no_border_on_floating = 1
      }
      windowrulev2 = noborder, focus:0
      windowrulev2 = noshadow, focus:0
      decoration {
	shadow:enabled = false
      }

      # Dwindle layout
      dwindle {
        pseudotile = true
        preserve_split = true
      }

      # Window rules
      windowrule = pseudo, title:Telegram
      windowrule = size 500 700, title:Telegram
      windowrulev2 = workspace 10 silent, class:^(Telegram)$

      # Mouse behavior for floating windows
      bindm = SUPER, mouse:272, movewindow
      bindm = SUPER, mouse:273, resizewindow

      # Keybinds
      bind = SUPER, Return, exec, $terminal
      bind = SUPER, Space, exec, $menu
      bind = SUPER SHIFT, L, exec, hyprlock
      bind = SUPER SHIFT, Return, exec, $browser
      bind = SUPER SHIFT, Q, killactive,
      bind = SUPER, E, exec, dolphin
      bind = SUPER, V, togglefloating,
      bind = SUPER, F, fullscreen,
      bind = SUPER, P, pseudo

      # Move focus
      bind = SUPER, H, movefocus, l
      bind = SUPER, L, movefocus, r
      bind = SUPER, K, movefocus, u
      bind = SUPER, J, movefocus, d

      # Workspaces
      bind = SUPER, 1, workspace, 1
      bind = SUPER, 2, workspace, 2
      bind = SUPER, 3, workspace, 3
      bind = SUPER, 4, workspace, 4
      bind = SUPER, 5, workspace, 5
      bind = SUPER, 6, workspace, 6
      bind = SUPER, 7, workspace, 7
      bind = SUPER, 8, workspace, 8
      bind = SUPER, 9, workspace, 9
      bind = SUPER, 0, workspace, 10
      bind = SUPER, N, togglespecialworkspace

      # Move window to workspace
      bind = SUPER SHIFT, 1, movetoworkspace, 1
      bind = SUPER SHIFT, 2, movetoworkspace, 2
      bind = SUPER SHIFT, 3, movetoworkspace, 3
      bind = SUPER SHIFT, 4, movetoworkspace, 4
      bind = SUPER SHIFT, 5, movetoworkspace, 5
      bind = SUPER SHIFT, 6, movetoworkspace, 6
      bind = SUPER SHIFT, 7, movetoworkspace, 7
      bind = SUPER SHIFT, 8, movetoworkspace, 8
      bind = SUPER SHIFT, 9, movetoworkspace, 9
      bind = SUPER SHIFT, 0, movetoworkspace, 10
      bind = SUPER SHIFT, N, movetoworkspace, special

      # Screenshot
      bind = SUPER SHIFT, S, exec, grim -g "$(slurp)" - | swappy -f -

      # Ignore maximize requests from apps. You'll probably like this.
      windowrulev2 = suppressevent maximize, class:.*

      # Fix some dragging issues with XWayland
      windowrulev2 = nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0

      windowrulev2 = immediate, class:.*

      # Resize mode using submap
      bind = SUPER, R, submap, resize

      submap = resize
          bind = , H, resizeactive, -60 0
          bind = , J, resizeactive, 0 60
          bind = , K, resizeactive, 0 -60
          bind = , L, resizeactive, 60 0
          bind = , left, resizeactive, -60 0
          bind = , down, resizeactive, 0 60
          bind = , up, resizeactive, 0 -60
          bind = , right, resizeactive, 60 0
          bind = , Return, submap, reset
          bind = , Escape, submap, reset
      submap = reset
      
      # Laptop multimedia keys for volume and LCD brightness
      bindel = ,XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
      bindel = ,XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
      bindel = ,XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
      bindel = ,XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
      bindel = ,XF86MonBrightnessUp, exec, brightnessctl s 10%+
      bindel = ,XF86MonBrightnessDown, exec, brightnessctl s 10%-
      bindel = ,XF86KbdBrightnessDown, exec, brightnessctl -d asus::kbd_backlight set 1-
      bindel = ,XF86KbdBrightnessUp, exec, brightnessctl -d asus::kbd_backlight set 1+
    '';
  };
}

