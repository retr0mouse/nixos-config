{ config, lib, pkgs, ... }:
{
  programs.waybar = {
    enable = true;

    settings = [
      {
        modules-left = [
          "group/workspaces"
          "group/brightvol"
          "mpris"
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

        mpris = {
          format = "[ {status_icon} | {dynamic} ]";
          interval = 1;
          dynamic-len = 40;
          status-icons = {
            playing = "▶";
            paused = "⏸";
            stopped = "";
          };
          dynamic-order = [ "artist" ];
        };

	"group/performance" = {
	  orientation = "horizontal";
	  modules =
	    [
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
          on-click = "kitty -e nvidia-smi";
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
            default = [ "" "" "" ];
          };
          on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          on-click-right = "pavucontrol";
        };

        backlight = {
          format = "{icon} {percent}%";
          format-icons = [ "🌙" "" "" ];
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
          tooltip-format =
            "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
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
          format-icons = [ "" "" "" "" "" ];
          on-click = "wlogout";
        };

        "custom/swaync" = {
          format = "";
          exec = "swaync-client -swb";
          on-click = "swaync-client --toggle-panel";
          interval = 0;
        };

        network = {
          interface = "wlan0";
          format-wifi = "{icon}";
          format-ethernet = "󰈀 LAN";
          format-disconnected = "󰖪";
          tooltip-format = "{ipaddr}\n{essid} ({signalStrength}%)";
          on-click = "kitty -e impala";
          format-icons = [ "󰤯" "󰤟" "󰤢" "󰤥" "󰤨" ];
        };

        "custom/bluetooth" = {
          format = "{}";
          exec = "bluetooth_status";
          interval = 5;
          on-click = "kitty -e bluetui";
        };
      }
    ];

    style = ''
    /* colors defined at top for easy configuring */
@define-color background #2C2A24;
@define-color second-background #3A372F;
@define-color text #DDD5C4;
@define-color borders #A0907A;
@define-color focused #D08B57;
@define-color focused2 #BFAA80;
@define-color color1 #7699A3;
@define-color color2 #8D7AAE;
@define-color color3 #78997A;
@define-color urgent #B05A5A;


/* font declared */
* {
  font-family: "Iosevka";
  font-size: 15px;
}

/* idk what all this does */
window#waybar {
  background-color: @background;
  border-bottom: 0;
  color: @text;
  transition: background-color 0.5s;
}

window#waybar.hidden {
  opacity: 0.2;
}

window#waybar.empty #window {
  background-color: transparent;
}

#custom-openbracket,
#custom-closebracket,
#custom-split {
  margin: 0 5px;
}

/* whats this?? */
button {
  border: none;
}


/* left island */

#custom-arch:hover {
  color: @color1;
}

#custom-powerprofile:hover {
  color: @color1
}

#custom-themeswitcher:hover {
  color: @color1;
}

/* workspace pannel */
#workspaces button {
  min-width: 0;
  background-color: transparent;
  color: @text;
  border-radius: 0;
}

#workspaces button:hover {
  background-color: @second-background;
}

#workspaces button.active {
  color: @focused2;
  background-color: @second-background;
}

#workspaces button.urgent {
  background-color: @urgent;
}

/* no idea what this does */
.modules-left>widget:first-child>#workspaces {
  margin-left: 0;
}

.modules-right>widget:last-child>#workspaces {
  margin-right: 0;
}

/* media player */
#mpris {
  margin: 0 0 0 5px;
  color: @text;
}

#mpris.playing {
  background-color: @color3;
  border-radius: 2px;
}

/* Right Island */

#clock:hover,
#battery:hover,
#custom-cpu:hover,
#custom-clipboard:hover,
#custom-bluetooth:hover,
#network:hover,
#idle_inhibitor:hover,
#custom-swaync:hover,
#backlight:hover,
#wireplumber:hover {
  color: @color1;
}

#wireplumber.muted {
  background-color: @color2;
}

#custom-swaync {
  font-size: 16px;
  /* same scale as other icons */
  color: @text;
}

#battery {
  padding: 0 5px;
}

#battery.charging,
#battery.plugged {
  background-color: @focused2 ;
  color: @background;
}

#battery.critical:not(.charging) {
  background-color: @urgent;
  color: @text;
  animation: blink 0.5s steps(12) infinite alternate;
}

@keyframes blink {
  to {
    background-color: @second-background;
    color: @text;
  }
}

    '';
  };
}
