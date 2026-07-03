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

  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  networking.hostName = "nico";
  networking.networkmanager.enable = true;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [];
    allowedUDPPorts = [ 51820 ];
    extraCommands = ''
      iptables -P INPUT DROP
      iptables -P FORWARD DROP
      iptables -P OUTPUT ACCEPT

      iptables -A INPUT -i lo -j ACCEPT
      iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

      iptables -A INPUT -s 192.168.0.0/24 -j ACCEPT
      iptables -A INPUT -s 10.10.0.0/24 -j ACCEPT
      iptables -A INPUT -p udp --dport 51820 -j ACCEPT
    '';
  };

  networking.wireguard.interfaces.wg0 = { 
    ips = [ 
      "10.10.0.1/24" 
    ]; 
    listenPort = 51820; 
    privateKeyFile = "/etc/wireguard/privatekey"; 
    peers = [ 
      { 
        publicKey = "Q0fqgzyFCBaBUl9R/AByAdj0UmsngUEX9t0c6vc7QBw="; 
        allowedIPs = [ "10.10.0.2/32" ]; 
      }
      {
        publicKey = "BCUiOnONmcZEb3Bit6tqfQYXpdPhxYxPP/Ljd8gmxhg=";
        allowedIPs = [ "10.10.0.4/32" ];
      }
    ]; 
  };

  services.duckdns = {
    enable = true;

    domains = [
      "voldsoy"
    ];

    tokenFile = "/etc/secrets/duckdns-token";
  };

  services.nginx = {
    enable = true;

    virtualHosts."immich.dema" = {
      listen = [
        { addr = "10.10.0.1"; port = 80; }
        { addr = "192.168.0.251"; port = 80; }
      ];

      locations."/" = {
        proxyPass = "http://127.0.0.1:2283";

        extraConfig = ''
          client_max_body_size 0;
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;

          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "upgrade";
        '';
      };
    };


    virtualHosts."pihole.dema" = {
      listen = [
        { addr = "10.10.0.1"; port = 80; }
        { addr = "192.168.0.251"; port = 80; }
      ];

      locations."/" = {
        proxyPass = "http://127.0.0.1:8081";

        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
        '';
      };
    };

    recommendedProxySettings = true;
    recommendedGzipSettings = true;
  };

  fileSystems."/data" = {
    device = "/dev/disk/by-uuid/efee3c35-c283-4091-9a72-5df4cfcb2412";
    fsType = "ext4";
    options = [ "noatime" "nofail" "x-systemd.device-timeout=5s" ];
  };

  systemd.tmpfiles.rules = [
    "d /data/immich 0750 immich immich -"
    "d /data/immich/library 0750 immich immich -"
    "d /data/immich/upload 0750 immich immich -"
    "d /data/immich/thumbs 0750 immich immich -"
    "d /data/immich/postgres 0700 postgres postgres -"
  ];

  services.postgresql = {
    enable = true;
    dataDir = "/data/postgres/immich";

    authentication = pkgs.lib.mkOverride 10 ''
      local all all trust
      host all all 127.0.0.1/32 trust
      host all all ::1/128 trust
    '';
  };

  services.immich = {
    enable = true;

    host = "127.0.0.1";
    port = 2283;

    mediaLocation = "/data/immich/library";

    settings.server.externalDomain = "http://immich.home";
  };

  users.users.immich = {
    isSystemUser = true;
    group = "immich";
    home = "/var/lib/immich";
  };

  users.groups.immich = {};

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
    settings.server = {
      interface = [ "127.0.0.1" ];
      port = 5335;
      hide-identity = true;
      hide-version = true;
      qname-minimisation = true;
      prefetch = true;
    };
  };

  services.pihole-web = {
    enable = true;
    ports = [ "10.10.0.1:8081" ];
  };

  services.pihole-ftl = {
    enable = true;
    settings = {
      dns.interface = "127.0.0.1";
      dns.upstreams = [ "127.0.0.1#5335" ];
      dns.hosts = [
        "192.168.0.251 immich.dema"
        "192.168.0.251 pihole.dema"
      ];

      adlists = [
        "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
        "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/pro.txt"
      ];
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
