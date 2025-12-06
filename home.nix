{ config, pkgs, lib, ... }:

{
  imports = [
    ./hyprland.nix
  ];

  home.username = "retr0mouse";
  home.homeDirectory = "/home/retr0mouse";

  home.stateVersion = "24.11"; # Please read the comment before changing.

  home.packages = [
  ];
  wayland.windowManager.hyprland.systemd.enable = false;
  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
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
  
  # zsh config
  programs.zsh = {
    enable = true;
    shellAliases = {
      ll = "ls -l";
      ".." = "cd ..";
    };
    oh-my-zsh.enable = true;
    oh-my-zsh.theme = "robbyrussell";
  };

  programs.kitty = lib.mkForce {
    enable = true;
    settings = {
	confirm_os_window_close = 0;
	enable_audio_bell = false;
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
