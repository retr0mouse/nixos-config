{
  config,
  inputs,
  lib,
  pkgs,
  user,
  ...
}: {
  imports = [
    ./common.nix
    inputs.xremap-flake.nixosModules.default
  ];

  # Input / Key remapping
  services.xremap = {
    enable = true;
    serviceMode = "user";
    withWlroots = true;
    userName = user;

    config = {
      virtual_modifiers = ["CapsLock"];
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

  # Core desktop services
  services = {
    upower.enable = true;
    pcscd.enable = true;
    power-profiles-daemon.enable = true;
    gvfs.enable = true;
    udisks2.enable = true;
  };

  security = {
    polkit.enable = true;
    rtkit.enable = true;
  };

  # Spotify LAN sync
  networking.firewall.allowedTCPPorts = [ 57621 ];

  # Networking (iwd + NetworkManager)
  networking = {
    networkmanager.enable = true;
    networkmanager.wifi.backend = "iwd";

    wireless.iwd = {
      enable = true;
      settings.Settings.AutoConnect = true;
    };
  };

  systemd.services.NetworkManager-wait-online.enable = false;

  # Boot / splash
  boot = {
    plymouth = {
      enable = true;
      theme = "breeze";
    };

    consoleLogLevel = 0;
    initrd.verbose = false;

    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];
  };

  # Display Manager
  services.displayManager.ly.enable = true;

  programs = {
    xwayland.enable = true;
    hyprland.enable = true;

    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };

    gamescope.enable = true;
  };

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # Audio
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # Fonts
  fonts.packages = with pkgs; [
    jetbrains-mono
    font-awesome
    fira-code
    material-design-icons
    fantasque-sans-mono
    ubuntu-sans
    iosevka
  ];

  # Keyboard layout (X11 fallback — keep in sync with Hyprland kb_layout)
  services.xserver.xkb = {
    layout = "ee(us),ru";
    options = "grp:ctrl_space_toggle";
  };

  # XDG portals
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-hyprland
    ];
  };

  # User
  users.users.${user}.extraGroups = lib.mkAfter [
    "input"
    "video"
    "render"
  ];
}
