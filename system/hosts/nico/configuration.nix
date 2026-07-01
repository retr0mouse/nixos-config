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

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
  };

  networking.hostName = "nico";
  networking.networkmanager.enable = true;

  networking.firewall = {
    enable = true;
    allowedUDPPorts = [ 51820 ];

    interfaces.wg0 = {
      allowedTCPPorts = [ 80 443 8081 2283 53 22 ];
      allowedUDPPorts = [ 53 ];
    };
  };

  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.10.0.1/24" ];
    listenPort = 51820;

    privateKeyFile = "/etc/wireguard/wg0.key";

    peers = [
      {
        publicKey = "JbT9PlYI6wShpxbKeLj3uwffSBn4y5fy2oHiLSVoJHQ=";
        allowedIPs = [ "10.10.0.2/32" ];
      }
    ];
  };

  networking.nat = {
    enable = true;
    externalInterface = "enp3s0";
    internalInterfaces = [ "wg0" ];
  };

  services.nginx = {
    enable = true;

    virtualHosts."immich.home" = {
      listen = [
        {
          addr = "10.10.0.1";
          port = 80;
        }
      ];

      locations."/" = {
        proxyPass = "http://127.0.0.1:2283";

        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
        '';
      };
    };

    virtualHosts."pihole.home" = {
      listen = [
        {
          addr = "10.10.0.1";
          port = 80;
        }
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
      dns.interface = "10.10.0.1";
      dns.upstreams = [ "127.0.0.1#5335" ];
      dns.hosts = [
        "10.10.0.1 immich.home"
        "10.10.0.1 pihole.home"
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
