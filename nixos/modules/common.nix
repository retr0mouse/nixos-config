{ config, inputs, lib, pkgs, user, ... }:

{
  imports =
    [
      inputs.xremap-flake.nixosModules.default
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
  
  # Display Mananger
  services.displayManager.ly.enable = true;

  programs.xwayland.enable = true;

  programs.hyprland = {
    enable = true;
  };

  # Enable Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bluetooth
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot

  # Set time zone.
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

  users.users.${user} = {
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

  xdg.portal = {
    enable = true;

    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
    ];

    config = {
      common.default = [
        "hyprland"
        "gtk"
      ];
    };
  };

  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [
  	amdgpu_top
	clinfo
	evtest
	mesa-demos
	libva
	ffmpeg
	nvidia-vaapi-driver
	vulkan-tools
	docker-compose
	lshw
	fastfetch
	htop
	btop
  ];

  system.stateVersion = "25.05";
}


