
{ config, pkgs, lib, ... }:

{
  imports = [
    ./hyprland.nix
  ];

  home.username = "retr0mouse";
  home.homeDirectory = "/home/retr0mouse";

  home.stateVersion = "24.11"; # Please read the comment before changing.

  home.packages = [
	  pkgs.hyprlock
  ];
  wayland.windowManager.hyprland.systemd.enable = false;
  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };

  programs.ssh = {
    enable = true;
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

  programs.wofi = {
    enable = true;
    settings = {
      insensitive = true;
      allow_images = true;
    };
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
          text = "$LAYOUT";   # current layout
          font_size = 12;
          font_color = "rgb(202, 211, 245)";
          position = "0, -200"; # adjust vertical position
          halign = "center";
          valign = "center"; 
      }
      {
          monitor = "";
          text = "$TIME";     # 24h format
          font_size = 44;
          font_color = "rgb(202, 211, 245)";
          position = "0, 100";  # adjust position below
          halign = "center";
          valign = "center";
      }
      ];
    };
  };

  # zsh 
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      config = "cd ~/dots";
      rebuild = "sudo nixos-rebuild switch --flake ~/dots#reisdro";
    };
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "robbyrussell";
    };
  };


  programs.kitty = lib.mkForce {
    enable = true;
    settings = {
	confirm_os_window_close = 0;
	enable_audio_bell = false;
        background_opacity = 0.5;
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
