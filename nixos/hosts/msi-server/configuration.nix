{ config, pkgs, user, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };

  networking.hostName = "nico"; # Define your hostname.
  networking.networkmanager.enable = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 53 80 ];
    allowedUDPPorts = [ 53 ];
  };
  services.logind = {
    lidSwitch = "ignore";
    lidSwitchDocked = "ignore";
    lidSwitchExternalPower = "ignore";
  };
  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowHybridSleep=no
  '';

  services.timesyncd.enable = true; # question
  services.openssh = {
    enable = true;
    settings = {
      X11Forwarding = true;
      X11UseLocalhost = true;
      X11DisplayOffset = 10;
      AllowTcpForwarding = true;
    };
  };
  services.fstrim.enable = true; # question
  services.fail2ban.enable = true;
  services.unbound = {
    enable = true;
    settings = {
      server = {
        interface = [ "127.0.0.1" ];
	port = 5335;
	hide-identity = true;
	hide-version = true;
	qname-minimisation = true;
	prefetch = true;
      };
    };
  };
  services.pihole-web = {
    enable = true;
    ports = [ "80" ];
  };
  services.pihole-ftl = {
    enable = true;
    settings = {
      dns.interface = "0.0.0.0";
      dns.upstreams = [ "127.0.0.1#5335" ];
    };
  };

  services.journald.extraConfig = '' # to prevent log explosion
    SystemMaxUse=500M
  '';
  services.power-profiles-daemon.enable = true;

  time.timeZone = "Europe/Tallinn";

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "et_EE.UTF-8";
    LC_IDENTIFICATION = "et_EE.UTF-8";
    LC_MEASUREMENT = "et_EE.UTF-8";
    LC_MONETARY = "et_EE.UTF-8";
    LC_NAME = "et_EE.UTF-8";
    LC_NUMERIC = "et_EE.UTF-8";
    LC_PAPER = "et_EE.UTF-8";
    LC_TELEPHONE = "et_EE.UTF-8";
    LC_TIME = "et_EE.UTF-8";
  };

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  users.users.${user} = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
  };

  system.stateVersion = "25.11"; # Did you read the comment?

}
