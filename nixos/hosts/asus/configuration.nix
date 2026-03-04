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
    userName = "reisdro";
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
  
  networking.hostName = "ga503"; 

  # Display Mananger
  services.displayManager.ly.enable = true;

  programs.xwayland.enable = true;

  programs.hyprland = {
    enable = true;
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

    #Wayland support for specific apps
    MOZ_ENABLE_WAYLAND = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";

    #For Anki
    ANKI_WAYLAND = "1";
  };

  programs.neovim.defaultEditor = true;

  # Default apps
  xdg.mime.defaultApplications = {
    "text/html" = "brave.desktop";
    "x-scheme-handler/http" = "brave.desktop";
    "x-scheme-handler/https" = "brave.desktop";
    "x-scheme-handler/about" = "brave.desktop";
    "x-scheme-handler/unknown" = "brave.desktop";
  };


  # Font
  fonts.packages = with pkgs; [
      jetbrains-mono
      font-awesome
      fira-code
      material-design-icons
      fantasque-sans-mono
      ubuntu-sans
      iosevka
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
    wireplumber.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput = {
    enable = true;
    touchpad.naturalScrolling = true;
  };

  users.users.reisdro = {
    isNormalUser = true;
    shell = pkgs.zsh;   
    extraGroups = [ "wheel" "input" "docker" "network" "networkmanager" "video" "render" "postgres"];
  };

  programs.zsh.enable = true;

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
    amdgpu_top # htop for amd gpu
    jq # cli for processing JSON data
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
    lshw
    brave # brave browser

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
    tree # inspect folder structure
    bluetui # bluetooth TUI
  ];

  system.stateVersion = "25.05";
}

