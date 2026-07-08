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
  
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # IMPORTANT: disable nouveau
  boot.blacklistedKernelModules = [ "nouveau" ];

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

  services.jellyfin = {
    enable = true;
  };
  services.radarr = {
    enable = true;
    dataDir = "/var/lib/radarr";
  };
  services.sonarr = {
    enable = true;
    dataDir = "/var/lib/sonarr";
  };
  services.prowlarr = {
    enable = true;
  };

  services.qbittorrent = {
    enable = true;
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
    
    virtualHosts."jellyfin.dema" = {
      serverName = "jellyfin.dema";
      locations."/" = {
        proxyPass = "http://127.0.0.1:8096";

        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Forwarded-Host $host;

          proxy_http_version 1.1;

          # WebSockets (Jellyfin UI needs this)
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "upgrade";
        '';
      };
    };

    virtualHosts."qbittorrent.dema" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:8080";
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Real-IP $remote_addr;

          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "upgrade";
        '';
      };
    };

    virtualHosts."prowlarr.dema" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:9696";
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        '';
      };
    };

    virtualHosts."movies.dema" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:7878";
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        '';
      };
    };

    virtualHosts."shows.dema" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:8989";
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        '';
      };
    };
    virtualHosts."default" = {
      default = true;
      
      locations."/" = {
        return = "444";
      };
    };

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
    "d /data/media 0775 root media -"
    "d /data/media/movies 0775 root media -"
    "d /data/media/shows 0775 root media -"
    "d /data/downloads 0775 root media -"
    "d /var/lib/qBittorrent 0750 qbittorrent qbittorrent -"
    "d /data/qbittorrent 0750 qbittorrent qbittorrent -"
    "d /data/qbittorrent 0775 qbittorrent media -"
    "d /data/qbittorrent/downloads 0775 qbittorrent media -"
  ];
  systemd.services.qbittorrent.serviceConfig = {
    BindPaths = [ "/var/lib/qBittorrent" ];
  };
  systemd.services.radarr.after = [ "data.mount" ];
  systemd.services.sonarr.after = [ "data.mount" ];
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
  users.users.jellyfin.extraGroups = [ "media" "render" ];
  users.users.radarr.extraGroups = [ "media" ];
  users.users.sonarr.extraGroups = [ "media" ];
  users.users.qbittorrent.extraGroups = [ "media" ];

  users.groups.immich = {};
  users.groups.media = {};

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
    ports = [ "127.0.0.1:8081" ];
  };

  services.pihole-ftl = {
    enable = true;
    settings = {
      dns.interface = "127.0.0.1";
      dns.upstreams = [ "127.0.0.1#5335" ];
      dns.hosts = [
        "192.168.0.251 immich.dema"
        "192.168.0.251 pihole.dema"
        "192.168.0.251 jellyfin.dema"
        "192.168.0.251 qbittorrent.dema"
        "192.168.0.251 prowlarr.dema"
        "192.168.0.251 movies.dema"
        "192.168.0.251 shows.dema"
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
