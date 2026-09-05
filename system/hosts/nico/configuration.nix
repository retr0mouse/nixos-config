{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ../../modules/common.nix
    ./hardware-configuration.nix
  ];
  zramSwap.enable = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
  };

  # IMPORTANT: disable nouveau
  boot.blacklistedKernelModules = [ "nouveau" ];

  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  networking.hostName = "nico";
  networking.networkmanager.enable = true;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      25565
      443
    ];
    allowedUDPPorts = [
      51820
      24454
    ];
    trustedInterfaces = [
      "lo"
      "enp3s0"
      "wg0"
    ];
    extraCommands = ''
      iptables -A FORWARD -i wg0 -d 192.168.0.0/24 -j ACCEPT
      iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
    '';
    extraStopCommands = ''
      iptables -D FORWARD -i wg0 -d 192.168.0.0/24 -j ACCEPT 2>/dev/null || true
      iptables -D FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT 2>/dev/null || true
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
      {
        publicKey = "LxVWtEAwZUG/Il10eQqE93pnBW/uWWFloGi2E/bG0w4=";
        allowedIPs = [ "10.10.0.6/32" ];
      }
      {
        publicKey = "SF8AXo8cNOcS/NONhMRJ66NDbQDncSqoYYf3JVUt+So=";
        allowedIPs = [ "10.10.0.8/32" ];
      }
    ];
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "daniil.sharin667@gmail.com";
    certs."voldsoy.duckdns.org" = {
      domain = "voldsoy.duckdns.org";
      extraDomainNames = [ "*.voldsoy.duckdns.org" ];
      dnsProvider = "duckdns";
      dnsPropagationCheck = true;
      environmentFile = "/etc/secrets/duckdns-acme-env";
    };
  };

  users.users.nginx.extraGroups = [ "acme" ];

  services.jellyfin = {
    enable = true;
  };

  services.plex = {
    enable = true;
    extraFlags = [
      "--claim=claim-tt9ctr3x5deF9VuffTUT"
    ];
  };
  users.users.plex.extraGroups = [ "media" ];

  services.radarr = {
    enable = true;
  };
  services.sonarr = {
    enable = true;
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

    virtualHosts."immich.voldsoy.duckdns.org" = {
      useACMEHost = "voldsoy.duckdns.org";
      forceSSL = true;
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
    virtualHosts."pihole.voldsoy.duckdns.org" = {
      useACMEHost = "voldsoy.duckdns.org";
      forceSSL = true;
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

    virtualHosts."jellyfin.voldsoy.duckdns.org" = {
      useACMEHost = "voldsoy.duckdns.org";
      forceSSL = true;
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

    virtualHosts."plex.voldsoy.duckdns.org" = {
      useACMEHost = "voldsoy.duckdns.org";
      forceSSL = true;

      locations."/" = {
        proxyPass = "http://127.0.0.1:32400";
        proxyWebsockets = true;

        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;

          proxy_buffering off;
        '';
      };
    };

    virtualHosts."qbittorrent.voldsoy.duckdns.org" = {
      useACMEHost = "voldsoy.duckdns.org";
      forceSSL = true;
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

    virtualHosts."prowlarr.voldsoy.duckdns.org" = {
      useACMEHost = "voldsoy.duckdns.org";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:9696";
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
        '';
      };
    };

    virtualHosts."movies.voldsoy.duckdns.org" = {
      useACMEHost = "voldsoy.duckdns.org";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:7878";
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
        '';
      };
    };

    virtualHosts."shows.voldsoy.duckdns.org" = {
      useACMEHost = "voldsoy.duckdns.org";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8989";
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
        '';
      };
    };

    virtualHosts."lidarr.voldsoy.duckdns.org" = {
      useACMEHost = "voldsoy.duckdns.org";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8686";
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
        '';
      };
    };

    virtualHosts."music.voldsoy.duckdns.org" = {
      useACMEHost = "voldsoy.duckdns.org";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:4533";
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
        '';
      };
    };

    virtualHosts."uptime-kuma.voldsoy.duckdns.org" = {
      useACMEHost = "voldsoy.duckdns.org";
      forceSSL = true;

      locations."/" = {
        proxyPass = "http://127.0.0.1:3001";

        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;

          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "upgrade";
        '';
      };
    };

    virtualHosts."grafana.voldsoy.duckdns.org" = {
      useACMEHost = "voldsoy.duckdns.org";
      forceSSL = true;

      locations."/" = {
        proxyPass = "http://127.0.0.1:3000";

        extraConfig = ''
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

    virtualHosts."bitwarden.voldsoy.duckdns.org" = {
      useACMEHost = "voldsoy.duckdns.org";
      forceSSL = true;

      locations."/" = {
        proxyPass = "http://127.0.0.1:8222";
        proxyWebsockets = true;
      };
    };

    virtualHosts."seerr.voldsoy.duckdns.org" = {
      useACMEHost = "voldsoy.duckdns.org";
      forceSSL = true;

      locations."/" = {
        proxyPass = "http://127.0.0.1:5055";
        proxyWebsockets = true;
      };
    };

    virtualHosts."slskd.voldsoy.duckdns.org" = {
      useACMEHost = "voldsoy.duckdns.org";
      forceSSL = true;

      locations."/" = {
        proxyPass = "http://127.0.0.1:5030";
        proxyWebsockets = true;
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
    options = [
      "noatime"
      "nofail"
      "x-systemd.device-timeout=5s"
    ];
  };

  systemd.tmpfiles.rules = [
    # SSD-backed application state
    "d /var/lib/minecraft 0750 minecraft minecraft -"
    "d /var/lib/postgresql 0700 postgres postgres -"
    "d /var/lib/postgresql/immich 0700 postgres postgres -"

    # HDD-backed data
    "d /data/media 2775 root media -"
    "d /data/media/movies 2775 root media -"
    "d /data/media/shows 2775 root media -"
    "d /data/music 2775 root media -"
    "d /data/downloads 2775 root media -"
    "d /data/downloads/complete 2775 root media -"
    "d /data/downloads/incomplete 2775 root media -"
    "d /data/downloads/torrents 2775 root media -"
    "d /data/downloads/finished 2775 root media -"
    "d /data/downloads/slskd 2775 root media -"
    "d /data/downloads/slskd/complete 2775 root media -"
    "d /data/downloads/slskd/incomplete 2775 root media -"
    "d /data/immich 0750 immich immich -"
    "d /data/immich/library 0750 immich immich -"
    "d /data/immich/upload 0750 immich immich -"
    "d /data/immich/thumbs 0750 immich immich -"
  ];

  systemd.services.qbittorrent.serviceConfig.UMask = "0002";
  systemd.services.radarr.serviceConfig.UMask = lib.mkForce "0002";
  systemd.services.sonarr.serviceConfig.UMask = lib.mkForce "0002";
  systemd.services.lidarr.serviceConfig.UMask = "0002";

  systemd.services.qbittorrent.after = [ "data.mount" ];
  systemd.services.qbittorrent.requires = [ "data.mount" ];

  systemd.services.radarr.after = [ "data.mount" ];
  systemd.services.radarr.requires = [ "data.mount" ];

  systemd.services.sonarr.after = [ "data.mount" ];
  systemd.services.sonarr.requires = [ "data.mount" ];

  systemd.services.jellyfin.after = [ "data.mount" ];
  systemd.services.jellyfin.requires = [ "data.mount" ];

  systemd.services.immich-server.after = [ "data.mount" ];
  systemd.services.immich-server.requires = [ "data.mount" ];

  systemd.services.navidrome.after = [ "data.mount" ];
  systemd.services.navidrome.requires = [ "data.mount" ];

  systemd.services.lidarr.after = [ "data.mount" ];
  systemd.services.lidarr.requires = [ "data.mount" ];

  systemd.services.plex.after = [ "data.mount" ];
  systemd.services.plex.requires = [ "data.mount" ];

  systemd.services.slskd = {
    after = [
      "data.mount"
      "systemd-tmpfiles-setup.service"
    ];

    requires = [
      "data.mount"
      "systemd-tmpfiles-setup.service"
    ];

    serviceConfig.UMask = "0002";
  };

  services.postgresql = {
    enable = true;
    dataDir = "/var/lib/postgresql/immich";
  };

  systemd.services.smartctl-exporter = {
    description = "Prometheus SMART exporter";

    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      ExecStart = "${pkgs.prometheus-smartctl-exporter}/bin/smartctl_exporter";
      Restart = "always";
      User = "root";
    };
  };

  services.immich = {
    enable = true;

    host = "127.0.0.1";
    port = 2283;

    mediaLocation = "/data/immich/library";

    settings = {
      server.externalDomain = "https://immich.voldsoy.duckdns.org";

      ffmpeg = {
        accel = "nvenc";
        accelDecode = true;
      };
    };
  };

  users.users.immich = {
    isSystemUser = true;
    group = "immich";
    extraGroups = [ "render" ];
    home = "/var/lib/immich";
  };
  users.users.jellyfin.extraGroups = [
    "media"
    "render"
  ];
  users.users.radarr.extraGroups = [ "media" ];
  users.users.sonarr.extraGroups = [ "media" ];
  users.users.qbittorrent.extraGroups = [ "media" ];
  users.users.navidrome.extraGroups = [ "media" ];
  users.users.lidarr.extraGroups = [ "media" ];
  users.users.slskd.extraGroups = [ "media" ];

  users.groups.immich = { };
  users.groups.media = { };

  services.logind = {
    lidSwitch = "ignore";
    lidSwitchDocked = "ignore";
    lidSwitchExternalPower = "ignore";
  };

  systemd.sleep.settings.Sleep = {
    AllowSuspend = "no";
    AllowHibernation = "no";
    AllowHybridSleep = "no";
  };

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
        "192.168.0.251 immich.voldsoy.duckdns.org"
        "192.168.0.251 pihole.voldsoy.duckdns.org"
        "192.168.0.251 jellyfin.voldsoy.duckdns.org"
        "192.168.0.251 qbittorrent.voldsoy.duckdns.org"
        "192.168.0.251 prowlarr.voldsoy.duckdns.org"
        "192.168.0.251 movies.voldsoy.duckdns.org"
        "192.168.0.251 shows.voldsoy.duckdns.org"
        "192.168.0.251 uptime-kuma.voldsoy.duckdns.org"
        "192.168.0.251 grafana.voldsoy.duckdns.org"
        "192.168.0.251 music.voldsoy.duckdns.org"
        "192.168.0.251 lidarr.voldsoy.duckdns.org"
        "192.168.0.251 bitwarden.voldsoy.duckdns.org"
        "192.168.0.251 seerr.voldsoy.duckdns.org"
        "192.168.0.251 slskd.voldsoy.duckdns.org"
        "192.168.0.251 plex.voldsoy.duckdns.org"
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
  services.minecraft-servers = {
    dataDir = "/var/lib/minecraft";
    enable = true;
    eula = true;
    openFirewall = true;

    servers.fabric = {
      enable = true;
      jvmOpts = "-Xmx6G -Xms4G";
      package = pkgs.fabricServers.fabric.override { jre_headless = pkgs.jdk25; };

      serverProperties = {
        server-port = 25565;
        difficulty = "normal";
        max-players = 3;
        motd = "This is NixOS btw";
        online-mode = false;
        view-distance = 10;
        simulation-distance = 8;
        enable-rcon = true;
        "rcon.password" = "minecraft2";
        white-list = true;
      };

      whitelist = {
        Nuacho = "f25c569a-a629-3a07-a3b6-aadbf29cc275";
        Alopopik = "2c2c1d1f-15ea-3c8f-94c3-96a87ea11c5e";
        aO_Oa = "fa25df27-d29b-3689-a4e3-1733fd9b0c40";
      };

      operators = {
        Nuacho = {
          uuid = "f25c569a-a629-3a07-a3b6-aadbf29cc275";
          level = 4;
        };
      };
      symlinks = {
        mods = pkgs.linkFarmFromDrvs "mods" (
          builtins.attrValues {
            Fabric-API = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/lVXlbH4w/fabric-api-0.155.2%2B26.2.jar";
              sha512 = "cc56984378a27c5bcd56374d6ffbb27a45c6bf3355add2ac6be9817ccac5854362249bf9d0147eb271a70fda2716129204e240d53c9aa876a2a7861f4c7f880f";
            };
            Simple-Voice-Chat = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/9eGKb6K1/versions/bvaEHE2T/voicechat-fabric-2.6.20%2B26.2.jar";
              sha512 = "6d9e16ef5e86b60c637797631f55c5ab3adbb8a8ee1e67f1d6b4f3c70fead800cf5d927a2f5f0eb6de5bc806088ae0d39a8ad3293c98d13936684a03c5d81336";
            };
            Chunky = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/fALzjamp/versions/4Eotm6ov/Chunky-Fabric-1.5.3.jar";
              sha512 = "0b3amvi0lq0gkv59mi26s5wj7hghq2nh41vw2k7p7q7wn1yak5yqaxnp0bg8p7nb6vjpl8cwl82py613msawxzr58isc2ld45xzwfxq";
            };
            Distant-Horizons = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/uCdwusMi/versions/gBf0SaV1/DistantHorizons-3.2.0-b-26.2-fabric-neoforge.jar";
              sha512 = "1r9x1aw8lcqi6wdk0qgaakz910hk5zyjjnjqy3hbccjmjf7ls5lsm9i3qvj1bbn4cjf3ax74wqkqpqr96yr3n4750iw40m0frvqbf61";
            };
            Lithium = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/UPNexAfy/lithium-fabric-0.25.2%2Bmc26.2.jar";
              sha512 = "181rb8szs3h704pdx1m1gbxba8mrdy6i0jbbdik0fx9qyz9k2ndpbi135sridfck52j0axfahaxqnhj3zjxkap5v8n92zjvq1v66ryv";
            };
            Krypton = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/fQEb0iXm/versions/5WeL0Nkz/krypton-0.3.1.jar";
              sha512 = "175c7m2xnb8z261wjffgq8bms0cn41zfyjfpkza82llf0wvzlc47z2zkfxwclvadrgh9dw7i2fslpbqiz5k4qlazcx4jl00rlsazndq";
            };
            Spark = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/l6YH9Als/versions/iYFOl6lQ/spark-1.10.173-fabric.jar";
              sha512 = "3xxphxvc0bx1qyqkyncdbp8hw1mkv6290i6lg2im7nmmjnjkwbsbhjb955fl6khpf4fav6cfy033c156qyzdsps7990gkzadjvz5jqx";
            };
            Fabric-Exporter = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/dbVXHSlv/versions/tuPsGk8g/fabricexporter-26.2-1.0.22.jar";
              sha512 = "1q0hxjjp20mh5pihm5a5girmkjmq2zfxaijxvxy2ysmr1676pm8ia06jqs8zghx3hzvg5igxdsa8svp37fx1wbzfwp1s34hi71mqiw0";
            };
            Universal-Graves = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/yn9u3ypm/versions/BZfhXd0q/graves-3.12.0%2B26.2.jar";
              sha512 = "09k12wyys34dwhcn4ihprv5y3vs4j69lf68zh4b79bb9pa88hv7dckz9jkk3lx60s9d7mzbhik2a3mc8r7wk3qjsx8k6cdicfq557s9";
            };
            Polymer = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/xGdtZczs/versions/NTeStfxi/polymer-bundled-0.17.4%2B26.2.jar";
              sha512 = "3zqvk7kb8ckf5qc91pj7j9fi8znqgfnlj13g98gxnw82i6db1zgg2kwlkmx120krv7rjfv5sqxhg77yqpx3xv3mjvkjfx99zzqriwdv";
            };
          }
        );
      };
    };
  };

  services.uptime-kuma = {
    enable = true;
  };

  services.prometheus = {
    enable = true;

    scrapeConfigs = [
      {
        job_name = "performance";
        static_configs = [
          {
            targets = [
              "127.0.0.1:9100"
            ];
          }
        ];
      }
      {
        job_name = "smartctl";
        static_configs = [
          {
            targets = [
              "127.0.0.1:9633"
            ];
          }
        ];
      }
      {
        job_name = "fabric";
        static_configs = [
          {
            targets = [
              "127.0.0.1:25585"
            ];
          }
        ];
      }
    ];

    exporters.node = {
      enable = true;
      enabledCollectors = [
        "systemd"
        "filesystem"
        "thermal_zone"
      ];
    };
  };

  services.grafana = {
    enable = true;

    settings = {
      security = {
        secret_key = "$__file{/etc/secrets/grafana-secret-key}";
      };
      server = {
        http_addr = "127.0.0.1";
        http_port = 3000;
        domain = "grafana.voldsoy.duckdns.org";
        root_url = "https://grafana.voldsoy.duckdns.org/";
      };
    };
  };

  services.smartd = {
    enable = true;
    autodetect = true;
  };

  services.navidrome = {
    enable = true;

    settings = {
      MusicFolder = "/data/music";
      Address = "127.0.0.1";
      Port = 4533;
    };
  };

  services.lidarr = {
    enable = true;
  };

  services.vaultwarden = {
    enable = true;

    environmentFile = "/var/lib/vaultwarden/vaultwarden.env";

    config = {
      DOMAIN = "https://bitwarden.voldsoy.duckdns.org";

      SIGNUPS_ALLOWED = true;

      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;

      ROCKET_LOG = "critical";
    };
  };

  services.flaresolverr = {
    enable = true;
    port = 8191;
  };

  services.seerr = {
    enable = true;
  };

  services.slskd = {
    enable = true;

    environmentFile = "/etc/secrets/slskd.env";

    settings = {
      directories = {
        downloads = "/data/downloads/slskd/complete";
        incomplete = "/data/downloads/slskd/incomplete";
      };

      shares = {
        directories = [
          "/data/music"
        ];
      };

      web = {
        port = 5030;
        authentication = {
          disabled = true;
        };
      };
    };
  };

  environment.systemPackages = with pkgs; [
    kitty.terminfo
    smartmontools
    prometheus-smartctl-exporter
  ];

  system.stateVersion = "25.11";
}
