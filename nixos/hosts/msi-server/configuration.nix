{
  config,
  pkgs,
  user,
  ...
}: {
  imports = [
    ../../modules/common.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "nico";
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

  services.journald.extraConfig = ''
    SystemMaxUse=500M
  '';
  environment.systemPackages = with pkgs; [
    kitty.terminfo
  ];
  system.stateVersion = "25.11";
}
