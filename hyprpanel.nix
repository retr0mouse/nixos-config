{ inputs, pkgs, ... }:
{
  imports = [ inputs.hyprpanel.homeManagerModules.hyprpanel ];

  programs.hyprpanel = {

    # Enable the module.
    # Default: false
    enable = true;

    # Automatically restart HyprPanel with systemd.
    # Useful when updating your config so that you
    # don't need to manually restart it.
    # Default: false
    systemd.enable = true;

    # Add '/nix/store/.../hyprpanel' to your
    # Hyprland config 'exec-once'.
    # Default: false
    hyprland.enable = true;

    # Fix the overwrite issue with HyprPanel.
    # See below for more information.
    # Default: false
    overwrite.enable = true;

    # Configure and theme almost all options from the GUI.
    # Options that require '{}' or '[]' are not yet implemented,
    # except for the layout.
    # See 'https://hyprpanel.com/configuratio/settings.html'.
    # Default: <same as gui>
    settings = {
      bar.workspaces.show_numbered = true;
      wallpaper.enable = true;
      wallpaper.image = "/home/retr0mouse/dots/walls/lake_with_mountains.png";
      theme.matugen = true;
      theme.matugen_settings = {
	mode = "light";
      };

      notifications.ignore = [ "spotify" ];

        
      layout = {
        "bar.layouts" = {
          "*" = {
            left = [ "workspaces" ];
	    middle = [ "clock" ];
            right = [ "volume" "network" "bluetooth" "battery" "power"];
          };
	};
      };

      bar.clock = {
        format = "%a %b %d  %H:%M:%S";
	showIcon = false;
      };

      menus.clock = {
        time = {
          military = true;
        };
	weather.enabled = false;
      };

      menus.dashboard.directories.enabled = false;
      menus.dashboard.stats.enable_gpu = true;
      scalingPriority = "hyprland";
      theme.bar = {
      	transparent = false;
      	location = "bottom";
	margin_sides = "0";
	buttons.y_margins = "0";
	outer_spacing = "0";
      };

      theme.font = {
        name = "CaskaydiaCove NF";
        size = "16px";
      };
    };
  };
  home.packages = [ pkgs.hyprpanel ];
}
