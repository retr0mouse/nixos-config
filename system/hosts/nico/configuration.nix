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
    allowedTCPPorts = [53 80 2283]; # port 22 opened automatically by services.openssh
    allowedUDPPorts = [53];
  };

  services.nginx = {
    enable = true;

    virtualHosts."nico.immich" = {
      listen = [
        {
          addr = "0.0.0.0";
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

    virtualHosts."nico.pihole" = {
      listen = [
        {
          addr = "0.0.0.0";
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
    options = ["noatime" "nofail" "x-systemd.device-timeout=5s"];
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
    settings = {
      server = {
        externalDomain = "http://nico.immich";
      };
    };
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
    settings = {
      server = {
        interface = ["127.0.0.1"];
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
    ports = ["8081"];
  };

  services.pihole-ftl = {
    enable = true;
    settings = {
      dns.interface = "0.0.0.0";
      dns.upstreams = ["127.0.0.1#5335"];
      dns.hosts = [
        "192.168.0.251 nico.immich"
        "192.168.0.251 nico.pihole"
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
