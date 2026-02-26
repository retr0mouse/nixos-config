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
    serviceMode = "user";
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

  services.dbus.enable = true; # notifications 

  services.upower.enable = true;

  services.asusd.enable = true; # enable asus cli service

  services.power-profiles-daemon.enable = true; # to manage power profiles

  services.logind.lidSwitchExternalPower = "ignore";

  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 3d";
  };

  # Wifi 
  networking.networkmanager.enable = false;
  networking.wireless.iwd.enable = true;
  networking.wireless.iwd.settings = {
	Settings = {
		AutoConnect = true;
	};
  };

  # Spotify sync local tracks
  networking.firewall.allowedTCPPorts = [ 57621 ];

  services.pcscd.enable = true;

  # Tell p11-kit to load/proxy opensc-pkcs11.so, providing all available slots
  # (PIN1 for authentication/decryption, PIN2 for signing).
  environment.etc."pkcs11/modules/opensc-pkcs11".text = ''
    module: ${pkgs.opensc}/lib/opensc-pkcs11.so
  '';

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  nixpkgs.config.allowUnfree = true;
  
  networking.hostName = "reisdro"; 

  # Display Mananger
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = true;


  # Wrap Wayland into UWSM
  programs.hyprland.withUWSM = true;
  programs.hyprland.enable = true;
  programs.hyprland.xwayland.enable = true;
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

  # fix to run dynamically linked executables
  programs.nix-ld.enable = true;

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
    
    #Wayland-specific
    XDG_CURRENT_DESKTOP = "Hyprland";
    GDK_BACKEND = "wayland,x11";
    CLUTTER_BACKEND = "wayland";
    QT_QPA_PLATFORM = "wayland";

    #Wayland support for specific apps
    MOZ_ENABLE_WAYLAND = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";

    #For Anki
    ANKI_WAYLAND = "1";
  };

  programs.neovim.defaultEditor = true;

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
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
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
    extraGroups = [ "wheel" "docker" "network" "networkmanager" "video" "render" "postgres"];
  };

  programs.zsh.enable = true;

  programs.firefox.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; 
    dedicatedServer.openFirewall = true; 
  };

  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };


  # OpenGL
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  
  services.xserver.enable = true;
  services.xserver.videoDrivers = [
    "amdgpu"
    "nvidia"
  ];

  xdg.portal = {
    enable = true;
    extraPortals = [
	pkgs.xdg-desktop-portal-gtk
	pkgs.xdg-desktop-portal-hyprland
    ];
  };




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

    slurp # screen area selector
    grim # screenshot taker
    swappy # image editor

    wf-recorder # video recorder
    
    fastfetch
    chromedriver
    chromium
    obsidian
    wlogout
    swaylock-effects
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

    waybar

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
    gamescope # To run steam and games smoothly

    qbittorrent
    anki-bin
    jetbrains.idea-ultimate
    jetbrains.idea-community
    maven
    foliate # e-book reader

    impala # manage wifi connections
    audacity
    pulseaudio

    sl # train say choo-choo
    unrar # to unrar folders

    yazi # file explorer TUI
    fzf # fuzzy-finder
    gcc # c compiler
    swww # wallpaper daemon
    libnotify # send notifications to notification daemon
    swaynotificationcenter # notification daemon   
  ];

  system.stateVersion = "25.05";
}

