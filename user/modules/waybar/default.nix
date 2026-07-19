{...}: {
  programs.waybar = {
    enable = true;

    settings = [
      {
        position = "bottom";

        modules-left = [
          "group/workspaces"
          "group/brightvol"
        ];

        modules-center = [
          "custom/openbracket"
          "clock"
          "custom/closebracket"
        ];

        modules-right = [
          "group/performance"
          "group/system"
        ];

        "custom/openbracket" = {
          format = "[";
          tooltip = false;
        };

        "custom/closebracket" = {
          format = "]";
          tooltip = false;
        };

        "custom/split" = {
          format = "|";
          tooltip = false;
        };

        "custom/powerprofile" = {
          exec = "powerprofile display";
          on-click = "powerprofile toggle";
          interval = 5;
          tooltip = true;
          exec-tooltip = "powerprofile tooltip";
        };

        "group/workspaces" = {
          orientation = "horizontal";
          modules = [
            "custom/openbracket"
            "hyprland/workspaces"
            "custom/closebracket"
          ];
        };

        "hyprland/workspaces" = {
          all-outputs = true;
          warp-on-scroll = false;
          enable-bar-scroll = true;
          disable-scroll-wraparound = true;
          active-only = false;
          format = "{icon}";
        };

        "group/performance" = {
          orientation = "horizontal";
          modules = [
            "custom/openbracket"
            "cpu"
            "custom/split"
            "memory"
            "custom/closebracket"
          ];
        };

        cpu = {
          format = "CPU:{usage}%";
          tooltip = false;
          interval = 2;
          on-click = "kitty -e btop";
        };

        memory = {
          format = "RAM:{}%";
          tooltip = false;
          interval = 2;
          on-click = "kitty -e btop";
        };

        "custom/igpu" = {
          exec = "igpu_usage";
          interval = 2;
          format = "iGPU{}";
          on-click = "kitty -e amdgpu_top";
        };

        "custom/dgpu" = {
          exec = "dgpu_usage";
          interval = 2;
          format = "dGPU:{}";
          on-click = "kitty -e nvidia-smi";
        };

        "group/brightvol" = {
          orientation = "horizontal";
          modules = [
            "custom/openbracket"
            "backlight"
            "custom/split"
            "pulseaudio"
            "custom/closebracket"
          ];
        };

        pulseaudio = {
          scroll-step = 5;
          format = "{icon} {volume}%";
          format-muted = "󰝟";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = ["" "" ""];
          };
          on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          on-click-right = "pavucontrol";
        };

        backlight = {
          format = "{icon} {percent}%";
          format-icons = ["🌙" "" ""];
        };

        "group/system" = {
          orientation = "horizontal";
          modules = [
            "custom/openbracket"
            "network"
            "custom/split"
            "custom/bluetooth"
            "custom/split"
            "battery"
            "custom/split"
            "custom/swaync"
            "custom/closebracket"
          ];
        };

        clock = {
          format = "{:%H:%M}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };

        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-full = "{icon} {capacity}%";
          format-charging = " {capacity}%";
          format-plugged = " {capacity}%";
          format-icons = ["" "" "" "" ""];
          on-click = "wlogout";
        };

        "custom/swaync" = {
          format = "";
          exec = "swaync-client -swb";
          on-click = "swaync-client --toggle-panel";
          interval = 0;
        };

        network = {
          format-wifi = "{icon}";
          format-ethernet = "󰈀 LAN";
          format-disconnected = "󰖪";
          tooltip-format = "{ipaddr}\n{essid} ({signalStrength}%)";
          on-click = "kitty -e wlctl";
          format-icons = ["󰤯" "󰤟" "󰤢" "󰤥" "󰤨"];
        };

        "custom/bluetooth" = {
          format = "{}";
          exec = "bluetooth_status";
          interval = 5;
          on-click = "kitty -e bluetui";
        };
      }
    ];

    style = builtins.readFile ./style.css;
  };
}
