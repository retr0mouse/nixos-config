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

## Inspiration

- [Ampersand's NixOS config](https://github.com/Andrey0189/nixos-config-reborn/tree/master)
- [DerAnsari's rice](https://github.com/DerAnsari/hyprland-dots)
>>>>>>> temp
