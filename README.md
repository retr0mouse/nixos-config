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

NICO CONFIG 20/07/2026
```nix
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
    allowedTCPPorts = [ 25565 443 ];
    allowedUDPPorts = [ 51820 24454 ];
    trustedInterfaces = [ "lo" "enp3s0" "wg0" ];
    filterForward = true;
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
    defaults.email = "TODO@example.com"; # replace with a real address before rebuilding
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

    virtualHosts."immich.voldsoy.duckdns.org" = {
      serverAliases = [ "immich.dema" ];
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
      serverAliases = [ "pihole.dema" ];
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
      serverAliases = [ "jellyfin.dema" ];
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
      serverAliases = [ "qbittorrent.dema" ];
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
      serverAliases = [ "prowlarr.dema" ];
      useACMEHost = "voldsoy.duckdns.org";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:9696";
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        '';
      };
    };

    virtualHosts."movies.voldsoy.duckdns.org" = {
      serverAliases = [ "movies.dema" ];
      useACMEHost = "voldsoy.duckdns.org";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:7878";
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        '';
      };
    };

    virtualHosts."shows.voldsoy.duckdns.org" = {
      serverAliases = [ "shows.dema" ];
      useACMEHost = "voldsoy.duckdns.org";
      forceSSL = true;
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

    settings.server.externalDomain = "http://immich.dema";
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
  services.minecraft-servers = {
    dataDir = "/data/minecraft";
    enable = true;
    eula = true;
    openFirewall = true;

    servers.fabric = {
      enable = true;
      jvmOpts = "-Xmx4G -Xms2G";
      package = pkgs.fabricServers.fabric.override { jre_headless = pkgs.jdk25; };

      serverProperties = {
        server-port = 25565;
        difficulty = "normal";
        max-players = 5;
        motd = "voldsoy";
        online-mode = false;
        view-distance = 10;
        simulation-distance = 8;
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
          }
        );
      };
    };
  };

  environment.systemPackages = with pkgs; [
    kitty.terminfo
  ];

  system.stateVersion = "25.11";
}
```

## Inspiration

- [Ampersand's NixOS config](https://github.com/Andrey0189/nixos-config-reborn/tree/master)
- [DerAnsari's rice](https://github.com/DerAnsari/hyprland-dots)
