{ config, inputs, lib, pkgs, user, ... }:

{
  imports = [
    inputs.xremap-flake.nixosModules.default
  ];

  # -------------------------
  # Input / key remapping
  # -------------------------
  services.xremap = {
    enable = true;
    serviceMode = "user";
    withWlroots = true;
    userName = user;

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

  # -------------------------
  # Core services
  # -------------------------
  services.dbus.enable = true;
  services.upower.enable = true;
  services.pcscd.enable = true;
  services.power-profiles-daemon.enable = true;

  # Spotify LAN sync / misc
  networking.firewall.allowedTCPPorts = [ 57621 ];

  # -------------------------
  # Power / cleanup
  # -------------------------
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 3d";
  };

  # -------------------------
  # Networking (minimal assumptions)
  # -------------------------
  # networking.networkmanager.enable = false;
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend = "iwd";

  networking.wireless.iwd = {
    enable = true;
    settings.Settings.AutoConnect = true;
  };
  networking.dhcpcd.enable = false;
  systemd.services.NetworkManager-wait-online.enable = false; # disable waiting for networkmanager on boot

  # -------------------------
  # Bootloader
  # -------------------------
  boot.loader.systemd-boot.enable = true;

  # -------------------------
  # Flakes
  # -------------------------
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # -------------------------
  # Display manager / desktop
  # -------------------------
  services.displayManager.ly.enable = true;

  programs = {
    xwayland.enable = true;
    hyprland.enable = true;
    zsh.enable = true;

    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };

    gamescope.enable = true;
  };

  # -------------------------
  # Bluetooth
  # -------------------------
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # -------------------------
  # Time / locale
  # -------------------------
  time.timeZone = "Europe/Tallinn";

  i18n.defaultLocale = "en_CA.UTF-8";
  i18n.extraLocaleSettings.LC_TIME = "en_GB.UTF-8";

  # -------------------------
  # Docker
  # -------------------------
  virtualisation.docker.enable = true;

  # -------------------------
  # Filesystems / portals
  # -------------------------
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-hyprland
    ];
  };

  # -------------------------
  # nix-ld
  # -------------------------
  programs.nix-ld.enable = true;

  # -------------------------
  # Fonts
  # -------------------------
  fonts.packages = with pkgs; [
    jetbrains-mono
    font-awesome
    fira-code
    material-design-icons
    fantasque-sans-mono
    ubuntu-sans
    iosevka
  ];

  # -------------------------
  # Keyboard layout (X11 fallback)
  # -------------------------
  services.xserver.xkb = {
    layout = "ee,ru";
    options = "grp:ctrl_space_toggle";
  };

  # -------------------------
  # Audio
  # -------------------------
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # -------------------------
  # User
  # -------------------------
  users.users.${user} = {
    isNormalUser = true;
    shell = pkgs.zsh;

    extraGroups = [
      "wheel"
      "input"
      "docker"
      "network"
      "networkmanager"
      "video"
      "render"
      "postgres"
    ];
  };
}
