# NixOS Dotfiles
Personal NixOS configuration managed with [Nix Flakes](https://nixos.wiki/wiki/Flakes) and [Home Manager](https://github.com/nix-community/home-manager). Targets two machines: an ASUS Zephyrus laptop (desktop) and an MSI home server.

---

## Hosts

| Hostname | Machine | Role |
|---|---|---|
| `clancy` | ASUS Zephyrus GA503 | Desktop / daily driver |
| `nico` | MSI PC | Home server (Pi-hole, Unbound) |

Rebuild the current machine:
```bash
sudo nixos-rebuild switch --flake ~/dots#$(hostname)
```

---

## Structure

```
.
├── flake.nix                        # Flake inputs & host definitions
├── system/
│   ├── modules/
│   │   ├── common.nix               # Shared: nix settings, SSH, Docker, user, zsh
│   │   └── desktop.nix              # Desktop: Hyprland, audio, Bluetooth, fonts, xremap
│   └── hosts/
│       ├── clancy/                  # ASUS laptop — AMD iGPU + NVIDIA dGPU (PRIME offload)
│       └── nico/                    # Home server — Pi-hole + Unbound DNS
├── user/
│   ├── home.nix                     # Home Manager root: GTK, cursor, hyprlock, zsh, MIME
│   ├── programs.nix                 # Extra packages
│   ├── scripts.nix                  # Shell scripts via writeShellScriptBin
│   └── modules/
│       ├── hyprland.nix             # Hyprland config (keybinds, window rules, autostart)
│       ├── waybar.nix               # Waybar layout and styling
│       ├── kitty.nix                # Kitty terminal
│       ├── neovim.nix               # Neovim with LSP, Treesitter, conform.nvim
│       ├── git.nix                  # Git identity
│       └── brave.nix                # Brave browser flags
└── scripts/                         # Bash scripts bundled into PATH via scripts.nix
```

---

## Desktop Stack

| Layer | Tool |
|---|---|
| Window manager | [Hyprland](https://hyprland.org/) |
| Status bar | [Waybar](https://github.com/Alexays/Waybar) |
| Display manager | [ly](https://github.com/fairyglade/ly) |
| Terminal | [Kitty](https://sw.kovidgoyal.net/kitty/) |
| Editor | [Neovim](https://neovim.io/) |
| App launcher | [Rofi](https://github.com/davatorium/rofi) |
| Notifications | [SwayNC](https://github.com/ErikReider/SwayNotificationCenter) |
| Lock screen | [Hyprlock](https://github.com/hyprwm/hyprlock) |
| Wallpaper | [Waypaper](https://github.com/anufrievroman/waypaper) + [Hyprpaper](https://github.com/hyprwm/hyprpaper) |
| Clipboard | [cliphist](https://github.com/sentriz/cliphist) + wl-clipboard |
| Audio | PipeWire + WirePlumber |
| Key remapping | [xremap](https://github.com/xremap/xremap) (CapsLock → vim-style arrows) |

---

## Server Stack (msi-server)

| Service | Purpose |
|---|---|
| [Pi-hole](https://pi-hole.net/) | Network-wide ad blocking |
| [Unbound](https://nlnetlabs.nl/projects/unbound/) | Recursive DNS resolver (upstream for Pi-hole, port 5335) |
| [fail2ban](https://github.com/fail2ban/fail2ban) | SSH brute-force protection |
| OpenSSH | Remote access (password auth disabled) |

---

## Key Bindings (Hyprland)

| Binding | Action |
|---|---|
| `SUPER + Return` | Open terminal (Kitty) |
| `SUPER + Space` | App launcher (Rofi) |
| `SUPER + SHIFT + Return` | Open browser (Brave) |
| `SUPER + SHIFT + Q` | Close window |
| `SUPER + E` | File manager (Yazi in Kitty) |
| `SUPER + V` | Toggle floating |
| `SUPER + F` | Fullscreen |
| `SUPER + H/J/K/L` | Move focus |
| `SUPER + SHIFT + H/J/K/L` | Move window |
| `SUPER + R` → `H/J/K/L` | Resize submap |
| `SUPER + 1–9/0` | Switch workspace |
| `SUPER + SHIFT + 1–9/0` | Move window to workspace |
| `SUPER + N` | Toggle scratchpad |
| `SUPER + SHIFT + S` | Screenshot region → swappy |
| `Pause` | Lock screen (Hyprlock) |
| `CapsLock + I/J/K/L` | Up/Left/Down/Right |
| `CapsLock + U/O` | Ctrl+Left / Ctrl+Right |
| `CapsLock + M/.` | Home / End |

---

## Useful Aliases

| Alias | Command |
|---|---|
| `rebuild` | `sudo nixos-rebuild switch --flake ~/dots#$(hostname)` |
| `config` | `cd ~/dots && tree` |
| `slip` | Lock screen then suspend |
| `logthefuckout` | Terminate current user session |

---

## First Deploy Notes

After a fresh `nixos-rebuild switch`, create the per-machine monitor layout file that Hyprland sources at startup:

```bash
mkdir -p ~/.config/hypr
# Example for a single 1920x1080 display:
echo "monitor=,1920x1080@60,auto,1" > ~/.config/hypr/monitors.conf
```

Adjust the monitor line for your display(s). See the [Hyprland monitor docs](https://wiki.hyprland.org/Configuring/Monitors/) for syntax.

---

NICO CONFIG 23/07/2026
```nix
{
  config,
  pkgs,
  ...
}:
{
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
    "d /data/immich 0750 immich immich -"
    "d /data/immich/library 0750 immich immich -"
    "d /data/immich/upload 0750 immich immich -"
    "d /data/immich/thumbs 0750 immich immich -"
    "d /data/media 2775 root media -"
    "d /data/media/movies 2775 root media -"
    "d /data/media/shows 2775 root media -"
    "d /data/downloads 2775 root media -"
    "d /data/downloads/complete 2775 root media -"
    "d /data/downloads/incomplete 2775 root media -"
    "d /data/downloads/torrents 2775 root media -"
    "d /data/downloads/finished 2775 root media -"
    "d /data/postgres 0700 postgres postgres -"
    "d /data/postgres/immich 0700 postgres postgres -"
    "d /data/minecraft 0755 minecraft minecraft -"
  ];

  systemd.services.qbittorrent.after = [ "data.mount" ];
  systemd.services.qbittorrent.requires = [ "data.mount" ];
  systemd.services.qbittorrent.serviceConfig.UMask = "0002";
  systemd.services.radarr.after = [ "data.mount" ];
  systemd.services.radarr.requires = [ "data.mount" ];
  systemd.services.sonarr.after = [ "data.mount" ];
  systemd.services.sonarr.requires = [ "data.mount" ];
  systemd.services.jellyfin.after = [ "data.mount" ];
  systemd.services.jellyfin.requires = [ "data.mount" ];
  systemd.services.immich-server.after = [ "data.mount" ];
  systemd.services.immich-server.requires = [ "data.mount" ];
  systemd.services.postgresql.after = [ "data.mount" ];
  systemd.services.postgresql.requires = [ "data.mount" ];
  systemd.services.mc-fabric.after = [ "data.mount" ];
  systemd.services.mc-fabric.requires = [ "data.mount" ];
  
  services.postgresql = {
    enable = true;
    dataDir = "/data/postgres/immich";
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

    settings.server.externalDomain = "https://immich.voldsoy.duckdns.org";
  };

  users.users.immich = {
    isSystemUser = true;
    group = "immich";
    home = "/var/lib/immich";
  };
  users.users.jellyfin.extraGroups = [
    "media"
    "render"
  ];
  users.users.radarr.extraGroups = [ "media" ];
  users.users.sonarr.extraGroups = [ "media" ];
  users.users.qbittorrent.extraGroups = [ "media" ];

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
    dataDir = "/data/minecraft";
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
        max-players = 5;
        motd = "This is NixOS btw";
        online-mode = false;
        view-distance = 10;
        simulation-distance = 8;
        enable-rcon = true;
        "rcon.password" = "minecraft2";
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

  environment.systemPackages = with pkgs; [
    kitty.terminfo
    smartmontools
    prometheus-smartctl-exporter
  ];

  system.stateVersion = "25.11";
}

```

## Inspiration

- [Ampersand's NixOS config](https://github.com/Andrey0189/nixos-config-reborn/tree/master)
- [DerAnsari's rice](https://github.com/DerAnsari/hyprland-dots)
