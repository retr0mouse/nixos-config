{
  pkgs,
  user,
  ...
}: {
  imports = [
    ./modules/hyprland
    ./modules/waybar
    ./modules/kitty.nix
    ./modules/zsh.nix
    ./modules/neovim
    ./modules/brave.nix
    ./modules/git.nix
    ./programs.nix
    ./scripts.nix
  ];

  services.hyprpolkitagent.enable = true;

  systemd.user.services.moniqued = {
    Unit = {
      Description = "Monique daemon - Auto-apply monitor profiles on hotplug";
      After = ["graphical-session.target"];
      PartOf = ["graphical-session.target"];
    };

    Service = {
      Type = "simple";
      ExecStart = "/run/current-system/sw/bin/moniqued";
      Restart = "on-failure";
      RestartSec = 5;
    };

    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };

  home = {
    username = user;
    homeDirectory = "/home/${user}";
  };

  home.stateVersion = "24.11"; # First-deploy version — do not change.

  wayland.windowManager.hyprland.systemd.enable = false;
  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.ssh = {
    enable = true;

    enableDefaultConfig = false;

    matchBlocks."*" = {
      addKeysToAgent = "yes";
      compression = true;
      serverAliveInterval = 60;
    };
  };

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
  };

  home.file = {
  };

  programs.rofi = {
    enable = true;
  };

  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        hide_cursor = false;
        ignore_empty_input = true;
      };

      animations = {
        enabled = true;
        fade_in = {
          duration = 300;
          bezier = "easeOutQuint";
        };
        fade_out = {
          duration = 300;
          bezier = "easeOutQuint";
        };
      };

      background = [
        {
          path = "screenshot";
          blur_passes = 3;
          blur_size = 8;
        }
      ];

      input-field = [
        {
          size = "200, 50";
          position = "0, -80";
          monitor = "";
          dots_center = true;
          fade_on_empty = false;
          font_color = "rgb(202, 211, 245)";
          inner_color = "rgb(91, 96, 120)";
          outer_color = "rgb(24, 25, 38)";
          outline_thickness = 5;
          shadow_passes = 2;
        }
      ];
      label = [
        {
          monitor = "";
          text = "$LAYOUT"; # current layout
          font_size = 12;
          font_color = "rgb(202, 211, 245)";
          position = "0, -200"; # adjust vertical position
          halign = "center";
          valign = "center";
        }
        {
          monitor = "";
          text = "$TIME"; # 24h format
          font_size = 44;
          font_color = "rgb(202, 211, 245)";
          position = "0, 100"; # adjust position below
          halign = "center";
          valign = "center";
        }
      ];
    };
  };

  # Default apps
  xdg.mimeApps = {
    enable = true;

    defaultApplications = {
      "text/html" = "brave.desktop";
      "x-scheme-handler/http" = "brave.desktop";
      "x-scheme-handler/https" = "brave.desktop";
      "x-scheme-handler/about" = "brave.desktop";
      "x-scheme-handler/unknown" = "brave.desktop";
    };
  };

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # Force Wayland for electron apps

    #Wayland support for specific apps
    MOZ_ENABLE_WAYLAND = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";

    #For Anki
    ANKI_WAYLAND = "1";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
