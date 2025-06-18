{ config, inputs, lib, pkgs, ... }:

{
  imports =
    [
      inputs.xremap-flake.nixosModules.default
      ./hardware-configuration.nix
    ];

  # xremap service
  services.xremap = {
    enable = true;
    serviceMode = "system";
    withWlroots = true;
    userName = "retr0mouse";
    config = {
      virtual_modifiers = [ "CapsLock" ];
      keymap = [
        {
	  remap = {
	    "CapsLock-i" = "Up";
  	    "CapsLock-j" = "Left";
	    "CapsLock-k" = "Down";
	    "CapsLock-l" = "Right";
            "CapsLock-m" = "Home";
            "CapsLock-dot" = "End";

	    "CapsLock-u" = "C-Left";
	    "CapsLock-o" = "C-Right";
	  };
        }
      ];
    };
  };

  systemd.user.services.monitorillo = {
    enable = true;
    description = "Monitorillo service";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      StandardOutput="append:/home/retr0mouse/monitorillo.out.log";
      StandardError="append:/home/retr0mouse/monitorillo.err.log";
      SyslogIdentifier="monitorillo";
      WorkingDirectory = "/home/retr0mouse";
      ExecStart = "/run/current-system/sw/bin/dotnet /home/retr0mouse/Code/monitorillo/bin/Debug/net9.0/monitorillo.dll";
      Restart = "on-failure";
      RestartSec = "5";
    };
  };

  services.upower.enable = true;

  # Wifi 
  networking.wireless.iwd.enable = true;
  networking.networkmanager.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  nixpkgs.config.allowUnfree = true;
  
  networking.hostName = "retr0mouseNixOs"; 

  # Display Mananger
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = true;


  # Wrap Wayland into UWSM
  programs.hyprland.withUWSM = true;
  programs.hyprland.enable = true;
  programs.xwayland.enable = true;

  # Firefox hardware acceleration
  programs.firefox.preferences = {
    "media.ffmpeg.vaapi.enabled" = true;
    "media.rdd-ffmpeg.enabled" = true;
    "media.av1.enabled" = true;
    "gfx.x11-egl.force-enabled" = true;
    "widget.dmabuf.force-enabled" = true;
  };
  # Enable Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bluetooth
  services.blueman.enable = true;
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot

  # Set your time zone.
  time.timeZone = "Europe/Tallinn";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";
  i18n.extraLocaleSettings = {
    LC_TIME = "en_GB.UTF-8";
  };

  # Docker
  virtualisation.docker.enable = true;

  # Virtual file system and disks
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  # Power profiles with hyprpanel
  services.power-profiles-daemon.enable = true;

  # Dolphine theming
  programs.dconf.enable = true;
  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita";
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # Force Wayland for electron apps
    WLR_NO_HARDWARE_CURSORS = "1"; # Fixes cursor issues
    MOZ_ENABLE_WAYLAND = "1"; # Helps with some launchers
    STEAM_FORCE_DESKTOPUI_SCALING = "1"; # UI scaling fix
    SDL_VIDEODRIVER="wayland";
  };


  environment.variables = {
    WLR_NO_HARDWARE_CURSORS="1";
    MOZ_DISABLE_RDD_SANDBOX = "1";
    NVD_BACKEND = "direct";
    EGL_PLATFORM = "wayland";
    XDG_SESSION_TYPE = "wayland";
    XCURSOR_THEME = "Bibata-Modern-Classic";
    XCURSOR_SIZE = "24";
    QT_QPA_PLATFORMTHEME = "gnome";
    QT_STYLE_OVERRIDE = "adwaita";
    QT_QPA_PLATFORM_THEME = "gnome";
    QT_QPA_PLATFORM = "wayland";
    GDK_BACKEND = "wayland";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";
    SDL_VIDEODRIVER = "wayland";
    MOZ_ENABLE_WAYLAND = "1";
    CLUTTER_BACKEND = "wayland";
  };

  # Default apps
  xdg.mime.defaultApplications = {
    "text/html" = "firefox.desktop";
    "x-scheme-handler/http" = "firefox.desktop";
    "x-scheme-handler/https" = "firefox.desktop";
    "x-scheme-handler/about" = "firefox.desktop";
    "x-scheme-handler/unknown" = "firefox.desktop";
  };


  # Font
  fonts.packages = with pkgs; [
      jetbrains-mono
      font-awesome
      fira-code
      material-design-icons
      fantasque-sans-mono
      ubuntu-sans
  ];

  # Configure keymap in X11
  services.xserver.xkb.layout = "ee+us, ru";
  services.xserver.xkb.options = "grp:ctrl_space_toggle";

  # Enable sound.
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.support32Bit = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput = {
    enable = true;
    touchpad.naturalScrolling = true;
  };

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.retr0mouse = {
    isNormalUser = true;
    shell = pkgs.zsh;   
    extraGroups = [ "wheel" "docker" "network" "networkmanager" "video" "render"];
  };

  programs.firefox.enable = true;
  programs.steam.enable = true;

  # zsh 
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      conf = "cd ~/dots";
      unixos = "sudo nixos-rebuild switch --flake ~/dots";
      uhome = "home-manager switch --flake .#retr0mouse -b backup";
    };
    ohMyZsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "robbyrussell";
    };
  };

  # OpenGL
  hardware.graphics = {
    enable = true;
  };
  
  services.xserver.enable = true;
  services.xserver.videoDrivers = [
    "amdgpu"
    "nvidia"
  ];


    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      powerManagement.finegrained = true;
      open = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      prime = {
        amdgpuBusId = lib.mkForce "PCI:6:0:0";
        nvidiaBusId = "PCI:1:0:0";
        offload = {
          enable = true;
	  enableOffloadCmd = true;
        };
      };
    };
  
  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [
    python310
    evtest
    htop
    btop
    neovim  
    kitty
    kdePackages.dolphin
    pavucontrol
    kdePackages.qtwayland
    kdePackages.qtsvg
    kdePackages.kio-fuse #to mount remote filesystems via FUSE
    kdePackages.kio-extras #extra protocols support (sftp, fish and more)
    wofi
    playerctl
    brightnessctl
    glxinfo
    clinfo
    wl-clipboard
    cliphist
    vulkan-tools
    _1password-gui
    hyprcursor
    bibata-cursors
    discord
    xorg.xkill
    telegram-desktop
    git
    gh
    docker-compose
    thefuck
    lshw
    slurp
    grim
    swappy
    fastfetch
    chromedriver
    chromium
    obsidian
    wlogout
    swaylock-effects
    hyprpaper
    gdm
    nodejs_24
    fira-code
    hollywood
    insomnia
    prismlauncher
    libreoffice-qt
    hunspell # libreOffice localization
    hunspellDicts.ru_RU
    hunspellDicts.en-us
    stremio
    spotify
    vlc
    matugen # theme change

    # hyprpanel requirements
    ags
    wireplumber
    networkmanager
    dart-sass
    upower
    gvfs
    gtksourceview3
    libgtop
    bluez 
    wf-recorder

    # gnome theming
    libsForQt5.qt5ct
    qgnomeplatform
    adwaita-qt

    libva
    ffmpeg
    nvidia-vaapi-driver

    nwg-displays # Monitor controll app
    dotnetCorePackages.sdk_9_0_1xx
    vscode
    hyprlock

    qdigidoc # DigiDoc client
    kdePackages.breeze-icons # Breeze icon theme
    papirus-icon-theme
  ];

  system.stateVersion = "25.05";
}

