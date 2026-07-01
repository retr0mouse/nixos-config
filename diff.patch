diff --git a/README.md b/README.md
index cf9623d..2438c22 100644
--- a/README.md
+++ b/README.md
@@ -1,6 +1,134 @@
-# NixOS configuration 
+# NixOS Dotfiles
+
 <img width="600" height="577" alt="image" src="https://github.com/user-attachments/assets/1e3229c5-5528-4fbc-af5d-cc9a24f970cc" />
 
+Personal NixOS configuration managed with [Nix Flakes](https://nixos.wiki/wiki/Flakes) and [Home Manager](https://github.com/nix-community/home-manager). Targets two machines: an ASUS Zephyrus laptop (desktop) and an MSI home server.
+
+---
+
+## Hosts
+
+| Hostname | Machine | Role |
+|---|---|---|
+| `clancy` | ASUS Zephyrus GA503 | Desktop / daily driver |
+| `nico` | MSI PC | Home server (Pi-hole, Unbound) |
+
+Rebuild the current machine:
+```bash
+sudo nixos-rebuild switch --flake ~/dots#$(hostname)
+```
+
+---
+
+## Structure
+
+```
+.
+├── flake.nix                        # Flake inputs & host definitions
+├── system/
+│   ├── modules/
+│   │   ├── common.nix               # Shared: nix settings, SSH, Docker, user, zsh
+│   │   └── desktop.nix              # Desktop: Hyprland, audio, Bluetooth, fonts, xremap
+│   └── hosts/
+│       ├── clancy/                  # ASUS laptop — AMD iGPU + NVIDIA dGPU (PRIME offload)
+│       └── nico/                    # Home server — Pi-hole + Unbound DNS
+├── user/
+│   ├── home.nix                     # Home Manager root: GTK, cursor, hyprlock, zsh, MIME
+│   ├── programs.nix                 # Extra packages
+│   ├── scripts.nix                  # Shell scripts via writeShellScriptBin
+│   └── modules/
+│       ├── hyprland.nix             # Hyprland config (keybinds, window rules, autostart)
+│       ├── waybar.nix               # Waybar layout and styling
+│       ├── kitty.nix                # Kitty terminal
+│       ├── neovim.nix               # Neovim with LSP, Treesitter, conform.nvim
+│       ├── git.nix                  # Git identity
+│       └── brave.nix                # Brave browser flags
+└── scripts/                         # Bash scripts bundled into PATH via scripts.nix
+```
+
+---
+
+## Desktop Stack
+
+| Layer | Tool |
+|---|---|
+| Window manager | [Hyprland](https://hyprland.org/) |
+| Status bar | [Waybar](https://github.com/Alexays/Waybar) |
+| Display manager | [ly](https://github.com/fairyglade/ly) |
+| Terminal | [Kitty](https://sw.kovidgoyal.net/kitty/) |
+| Editor | [Neovim](https://neovim.io/) |
+| App launcher | [Rofi](https://github.com/davatorium/rofi) |
+| Notifications | [SwayNC](https://github.com/ErikReider/SwayNotificationCenter) |
+| Lock screen | [Hyprlock](https://github.com/hyprwm/hyprlock) |
+| Wallpaper | [Waypaper](https://github.com/anufrievroman/waypaper) + [Hyprpaper](https://github.com/hyprwm/hyprpaper) |
+| Clipboard | [cliphist](https://github.com/sentriz/cliphist) + wl-clipboard |
+| Audio | PipeWire + WirePlumber |
+| Key remapping | [xremap](https://github.com/xremap/xremap) (CapsLock → vim-style arrows) |
+
+---
+
+## Server Stack (msi-server)
+
+| Service | Purpose |
+|---|---|
+| [Pi-hole](https://pi-hole.net/) | Network-wide ad blocking |
+| [Unbound](https://nlnetlabs.nl/projects/unbound/) | Recursive DNS resolver (upstream for Pi-hole, port 5335) |
+| [fail2ban](https://github.com/fail2ban/fail2ban) | SSH brute-force protection |
+| OpenSSH | Remote access (password auth disabled) |
+
+---
+
+## Key Bindings (Hyprland)
+
+| Binding | Action |
+|---|---|
+| `SUPER + Return` | Open terminal (Kitty) |
+| `SUPER + Space` | App launcher (Rofi) |
+| `SUPER + SHIFT + Return` | Open browser (Brave) |
+| `SUPER + SHIFT + Q` | Close window |
+| `SUPER + E` | File manager (Yazi in Kitty) |
+| `SUPER + V` | Toggle floating |
+| `SUPER + F` | Fullscreen |
+| `SUPER + H/J/K/L` | Move focus |
+| `SUPER + SHIFT + H/J/K/L` | Move window |
+| `SUPER + R` → `H/J/K/L` | Resize submap |
+| `SUPER + 1–9/0` | Switch workspace |
+| `SUPER + SHIFT + 1–9/0` | Move window to workspace |
+| `SUPER + N` | Toggle scratchpad |
+| `SUPER + SHIFT + S` | Screenshot region → swappy |
+| `Pause` | Lock screen (Hyprlock) |
+| `CapsLock + I/J/K/L` | Up/Left/Down/Right |
+| `CapsLock + U/O` | Ctrl+Left / Ctrl+Right |
+| `CapsLock + M/.` | Home / End |
+
+---
+
+## Useful Aliases
+
+| Alias | Command |
+|---|---|
+| `rebuild` | `sudo nixos-rebuild switch --flake ~/dots#$(hostname)` |
+| `config` | `cd ~/dots && tree` |
+| `slip` | Lock screen then suspend |
+| `logthefuckout` | Terminate current user session |
+
+---
+
+## First Deploy Notes
+
+After a fresh `nixos-rebuild switch`, create the per-machine monitor layout file that Hyprland sources at startup:
+
+```bash
+mkdir -p ~/.config/hypr
+# Example for a single 1920x1080 display:
+echo "monitor=,1920x1080@60,auto,1" > ~/.config/hypr/monitors.conf
+```
+
+Adjust the monitor line for your display(s). See the [Hyprland monitor docs](https://wiki.hyprland.org/Configuring/Monitors/) for syntax.
+
+---
+
 ## Inspiration
-[Ampersand's NixOS config](https://github.com/Andrey0189/nixos-config-reborn/tree/master)
-[DerAnsari's rice](https://github.com/DerAnsari/hyprland-dots)
+
+- [Ampersand's NixOS config](https://github.com/Andrey0189/nixos-config-reborn/tree/master)
+- [DerAnsari's rice](https://github.com/DerAnsari/hyprland-dots)
diff --git a/flake.nix b/flake.nix
index 436869c..e9bd26a 100644
--- a/flake.nix
+++ b/flake.nix
@@ -26,7 +26,7 @@
         };
 
         modules = [
-          ./nixos/hosts/${hostname}/configuration.nix
+          ./system/hosts/${hostname}/configuration.nix
 
           home-manager.nixosModules.home-manager
 
@@ -39,7 +39,7 @@
               inherit inputs user;
             };
 
-            home-manager.users.${user} = import ./home/home.nix;
+            home-manager.users.${user} = import ./user/home.nix;
           }
         ];
       };
@@ -52,13 +52,27 @@
         };
 
         modules = [
-          ./nixos/hosts/${hostname}/configuration.nix
+          ./system/hosts/${hostname}/configuration.nix
+
+          home-manager.nixosModules.home-manager
+
+          {
+            home-manager.useGlobalPkgs = true;
+            home-manager.useUserPackages = true;
+            home-manager.backupFileExtension = "backup";
+
+            home-manager.extraSpecialArgs = {
+              inherit inputs user;
+            };
+
+            home-manager.users.${user} = import ./user/home-server.nix;
+          }
         ];
       };
   in {
     nixosConfigurations = {
-      asus = mkDesktopHost "asus";
-      msi-server = mkServerHost "msi-server";
+      clancy = mkDesktopHost "clancy";
+      nico = mkServerHost "nico";
     };
   };
 }
diff --git a/home/modules/git.nix b/home/modules/git.nix
deleted file mode 100644
index f31dd69..0000000
--- a/home/modules/git.nix
+++ /dev/null
@@ -1,12 +0,0 @@
-{
-  programs.git = {
-    enable = true;
-    settings = {
-      user = {
-        name = "retr0mouse";
-        email = "daniil.sharin667@gmail.com";
-      };
-      init.defaultBranch = "main";
-    };
-  };
-}
diff --git a/scripts/bluetooth_status.sh b/scripts/bluetooth_status.sh
index 7c5f84e..b180f4d 100644
--- a/scripts/bluetooth_status.sh
+++ b/scripts/bluetooth_status.sh
@@ -1,20 +1,22 @@
 #!/usr/bin/env bash
 
 if ! command -v bluetoothctl >/dev/null; then
-    echo ""
+    echo ""
     exit 0
 fi
 
 adapter_powered=$(timeout 2 bluetoothctl show 2>/dev/null | awk -F': ' '/Powered:/ {print $2}')
 
 if [ "$adapter_powered" != "yes" ]; then
-    echo ""
+    echo ""
     exit 0
 fi
 
-if timeout 2 bluetoothctl devices Connected | grep -q .; then
-    device=$(timeout 2 bluetoothctl devices Connected | awk '{$1=$2=""; print substr($0,3)}')
-    echo " $device"
+connected=$(timeout 2 bluetoothctl devices Connected 2>/dev/null)
+
+if echo "$connected" | grep -q .; then
+    device=$(echo "$connected" | awk '{$1=$2=""; print substr($0,3)}')
+    echo " $device"
 else
-    echo ""
+    echo ""
 fi
diff --git a/scripts/clipboard_menu.sh b/scripts/clipboard_menu.sh
index a4dab5f..c571c77 100644
--- a/scripts/clipboard_menu.sh
+++ b/scripts/clipboard_menu.sh
@@ -1,3 +1,3 @@
 #!/usr/bin/env bash
 
-cliphist list | wofi --dmenu --width 700 --height 400 | cliphist decode | wl-copy
+cliphist list | rofi -dmenu -p "clipboard" -i | cliphist decode | wl-copy
diff --git a/scripts/igpu_usage.sh b/scripts/igpu_usage.sh
index 3cbba88..5bd2a0c 100644
--- a/scripts/igpu_usage.sh
+++ b/scripts/igpu_usage.sh
@@ -1,10 +1,11 @@
 #!/usr/bin/env bash
 
-# Find AMD GPU card
-CARD=$(ls /sys/class/drm | grep -E '^card[0-9]+$' | head -n1)
+CARD=$(ls /sys/class/drm/ | grep -E '^card[0-9]+$' | while read c; do
+    [ -f "/sys/class/drm/$c/device/gpu_busy_percent" ] && echo "$c" && break
+done)
 
-if [ -f "/sys/class/drm/card1/device/gpu_busy_percent" ]; then
-    cat /sys/class/drm/card1/device/gpu_busy_percent | awk '{print $1 "%"}'
+if [ -n "$CARD" ] && [ -f "/sys/class/drm/$CARD/device/gpu_busy_percent" ]; then
+    awk '{print $1 "%"}' "/sys/class/drm/$CARD/device/gpu_busy_percent"
 else
     echo "N/A"
 fi
diff --git a/scripts/powerprofile.sh b/scripts/powerprofile.sh
index 4f19661..6fd27f3 100644
--- a/scripts/powerprofile.sh
+++ b/scripts/powerprofile.sh
@@ -32,16 +32,12 @@ get_current_profile() {
 set_profile() {
   local mode="$1"
   if [ "$powerctl" = "powerprofilesctl" ]; then
-    if command -v powerprofilesctl &>/dev/null; then
-      powerprofilesctl set "$mode"
-    fi
+    powerprofilesctl set "$mode"
   elif [ "$powerctl" = "asusctl" ]; then
-    if [ "$1" = "power-saver" ]; then
+    if [ "$mode" = "power-saver" ]; then
       mode="quiet"
     fi
-    if command -v asusctl &>/dev/null; then
-      asusctl profile set "$mode"
-    fi
+    asusctl profile set "$mode"
   fi
 }
 
@@ -75,7 +71,7 @@ display_profile() {
     echo "BALANCED"
     ;;
   "performance")
-    echo "PERFORMANCE" 
+    echo "PERFORMANCE"
     ;;
   esac
 }
diff --git a/nixos/hosts/asus/configuration.nix b/system/hosts/clancy/configuration.nix
similarity index 92%
rename from nixos/hosts/asus/configuration.nix
rename to system/hosts/clancy/configuration.nix
index cffb060..03d702c 100644
--- a/nixos/hosts/asus/configuration.nix
+++ b/system/hosts/clancy/configuration.nix
@@ -12,13 +12,11 @@
     inputs.nixos-hardware.nixosModules.asus-zephyrus-ga503
   ];
 
-  networking.hostName = "ga503";
+  networking.hostName = "clancy";
 
   services.asusd.enable = true;
   services.logind.lidSwitchExternalPower = "ignore";
 
-  services.power-profiles-daemon.enable = true;
-
   services.libinput = {
     enable = true;
     touchpad.naturalScrolling = true;
@@ -51,4 +49,6 @@
   hardware.graphics.extraPackages = with pkgs; [
     mesa
   ];
+
+  system.stateVersion = "25.11";
 }
diff --git a/nixos/hosts/asus/hardware-configuration.nix b/system/hosts/clancy/hardware-configuration.nix
similarity index 100%
rename from nixos/hosts/asus/hardware-configuration.nix
rename to system/hosts/clancy/hardware-configuration.nix
diff --git a/nixos/hosts/msi-server/configuration.nix b/system/hosts/nico/configuration.nix
similarity index 94%
rename from nixos/hosts/msi-server/configuration.nix
rename to system/hosts/nico/configuration.nix
index 881c8e1..b154678 100644
--- a/nixos/hosts/msi-server/configuration.nix
+++ b/system/hosts/nico/configuration.nix
@@ -13,7 +13,7 @@
   networking.networkmanager.enable = true;
   networking.firewall = {
     enable = true;
-    allowedTCPPorts = [ 22 53 80 ];
+    allowedTCPPorts = [ 53 80 ]; # port 22 opened automatically by services.openssh
     allowedUDPPorts = [ 53 ];
   };
 
diff --git a/nixos/hosts/msi-server/hardware-configuration.nix b/system/hosts/nico/hardware-configuration.nix
similarity index 100%
rename from nixos/hosts/msi-server/hardware-configuration.nix
rename to system/hosts/nico/hardware-configuration.nix
diff --git a/nixos/modules/common.nix b/system/modules/common.nix
similarity index 93%
rename from nixos/modules/common.nix
rename to system/modules/common.nix
index 0330a3d..b02777c 100644
--- a/nixos/modules/common.nix
+++ b/system/modules/common.nix
@@ -53,8 +53,5 @@
   # nix-ld
   programs.nix-ld.enable = true;
   
-  environment.systemPackages = with pkgs; [
-    git
-    neovim
-  ];
+  environment.systemPackages = [];
 }
diff --git a/nixos/modules/desktop.nix b/system/modules/desktop.nix
similarity index 95%
rename from nixos/modules/desktop.nix
rename to system/modules/desktop.nix
index e335a14..7d0683d 100644
--- a/nixos/modules/desktop.nix
+++ b/system/modules/desktop.nix
@@ -65,7 +65,6 @@
       enable = true;
       settings.Settings.AutoConnect = true;
     };
-    dhcpcd.enable = true;
   };
 
   systemd.services.NetworkManager-wait-online.enable = false;
@@ -104,7 +103,7 @@
       dedicatedServer.openFirewall = true;
     };
 
-    gamescope.enable = true
+    gamescope.enable = true;
   };
 
   # Bluetooth
@@ -131,9 +130,9 @@
     iosevka
   ];
 
-  # Keyboard layout (X11 fallback)
+  # Keyboard layout (X11 fallback — keep in sync with Hyprland kb_layout)
   services.xserver.xkb = {
-    layout = "ee,ru";
+    layout = "ee(us),ru";
     options = "grp:ctrl_space_toggle";
   };
 
@@ -151,7 +150,5 @@
     "input"
     "video"
     "render"
-    "network"
-    "postgres"
   ];
 }
diff --git a/user/home-server.nix b/user/home-server.nix
new file mode 100644
index 0000000..c90e397
--- /dev/null
+++ b/user/home-server.nix
@@ -0,0 +1,47 @@
+{
+  pkgs,
+  user,
+  ...
+}: {
+  imports = [
+    ./modules/neovim.nix
+    ./modules/git.nix
+  ];
+
+  home = {
+    username = user;
+    homeDirectory = "/home/${user}";
+  };
+
+  home.stateVersion = "25.11"; # First-deploy version — do not change.
+
+  home.packages = with pkgs; [
+    btop
+    fzf
+    jq
+    tree
+    yazi
+    gh
+  ];
+
+  programs.ssh.enable = true;
+
+  programs.zsh = {
+    enable = true;
+    enableCompletion = true;
+    syntaxHighlighting.enable = true;
+
+    shellAliases = {
+      config = "cd ~/dots && tree";
+      rebuild = "sudo nixos-rebuild switch --flake ~/dots#$(hostname)";
+    };
+
+    oh-my-zsh = {
+      enable = true;
+      plugins = ["git"];
+      theme = "robbyrussell";
+    };
+  };
+
+  programs.home-manager.enable = true;
+}
diff --git a/home/home.nix b/user/home.nix
similarity index 93%
rename from home/home.nix
rename to user/home.nix
index da94b06..fda9554 100644
--- a/home/home.nix
+++ b/user/home.nix
@@ -23,11 +23,9 @@
     homeDirectory = "/home/${user}";
   };
 
-  home.stateVersion = "24.11"; # Please read the comment before changing.
+  home.stateVersion = "24.11"; # First-deploy version — do not change.
 
-  home.packages = [
-    pkgs.hyprlock
-  ];
+  home.packages = [];
   wayland.windowManager.hyprland.systemd.enable = false;
   gtk = {
     enable = true;
@@ -129,9 +127,9 @@
 
     shellAliases = {
       config = "cd ~/dots && tree";
-      rebuild = "sudo nixos-rebuild switch --flake ~/dots#msi-server";
+      rebuild = "sudo nixos-rebuild switch --flake ~/dots#$(hostname)";
       logthefuckout = "loginctl terminate-user $USER";
-      slip = "hyprlock & systemctl suspend";
+      slip = "hyprlock & sleep 0.5 && systemctl suspend";
     };
     oh-my-zsh = {
       enable = true;
diff --git a/home/modules/brave.nix b/user/modules/brave.nix
similarity index 100%
rename from home/modules/brave.nix
rename to user/modules/brave.nix
diff --git a/user/modules/git.nix b/user/modules/git.nix
new file mode 100644
index 0000000..84dcc56
--- /dev/null
+++ b/user/modules/git.nix
@@ -0,0 +1,16 @@
+{
+  programs.git = {
+    enable = true;
+    userName = "retr0mouse";
+    userEmail = "daniil.sharin667@gmail.com";
+    extraConfig.init.defaultBranch = "main";
+
+    delta = {
+      enable = true;
+      options = {
+        side-by-side = true;
+        line-numbers = true;
+      };
+    };
+  };
+}
diff --git a/home/modules/hyprland.nix b/user/modules/hyprland.nix
similarity index 100%
rename from home/modules/hyprland.nix
rename to user/modules/hyprland.nix
diff --git a/home/modules/kitty.nix b/user/modules/kitty.nix
similarity index 100%
rename from home/modules/kitty.nix
rename to user/modules/kitty.nix
diff --git a/home/modules/neovim.nix b/user/modules/neovim.nix
similarity index 95%
rename from home/modules/neovim.nix
rename to user/modules/neovim.nix
index 8cb6e2e..b7775e3 100644
--- a/home/modules/neovim.nix
+++ b/user/modules/neovim.nix
@@ -33,9 +33,6 @@
       vim.opt.shiftwidth = 4
       vim.opt.tabstop = 4
       vim.opt.expandtab = true
-      vim.opt.shiftwidth = 4
-      vim.opt.tabstop = 4
-      vim.opt.expandtab = true
       vim.opt.clipboard = "unnamedplus"
 
       vim.api.nvim_create_autocmd("FileType", {
diff --git a/home/modules/waybar.nix b/user/modules/waybar.nix
similarity index 94%
rename from home/modules/waybar.nix
rename to user/modules/waybar.nix
index 5866a13..ba9f3d3 100644
--- a/home/modules/waybar.nix
+++ b/user/modules/waybar.nix
@@ -95,7 +95,7 @@
           exec = "igpu_usage";
           interval = 2;
           format = "iGPU{}";
-          on-click = "kitty -e nvidia-smi";
+          on-click = "kitty -e amdgpu_top";
         };
 
         "custom/dgpu" = {
@@ -217,7 +217,6 @@
         font-size: 15px;
       }
 
-      /* idk what all this does */
       window#waybar {
         background-color: @background;
         border-bottom: 0;
@@ -239,27 +238,16 @@
         margin: 0 5px;
       }
 
-      /* whats this?? */
       button {
         border: none;
       }
 
 
-      /* left island */
-
-      #custom-arch:hover {
-        color: @color1;
-      }
-
       #custom-powerprofile:hover {
-        color: @color1
-      }
-
-      #custom-themeswitcher:hover {
         color: @color1;
       }
 
-      /* workspace pannel */
+      /* workspace panel */
       #workspaces button {
         min-width: 0;
         background-color: transparent;
@@ -280,7 +268,6 @@
         background-color: @urgent;
       }
 
-      /* no idea what this does */
       .modules-left>widget:first-child>#workspaces {
         margin-left: 0;
       }
@@ -293,18 +280,15 @@
 
       #clock:hover,
       #battery:hover,
-      #custom-cpu:hover,
-      #custom-clipboard:hover,
       #custom-bluetooth:hover,
       #network:hover,
-      #idle_inhibitor:hover,
       #custom-swaync:hover,
       #backlight:hover,
-      #wireplumber:hover {
+      #pulseaudio:hover {
         color: @color1;
       }
 
-      #wireplumber.muted {
+      #pulseaudio.muted {
         background-color: @color2;
       }
 
diff --git a/home/programs.nix b/user/programs.nix
similarity index 93%
rename from home/programs.nix
rename to user/programs.nix
index 50d4c11..7b99bdc 100644
--- a/home/programs.nix
+++ b/user/programs.nix
@@ -14,13 +14,10 @@
     dotnetCorePackages.sdk_9_0_1xx # dotnet 9.0.1 SDK
 
     # terminal / UI apps
-    kitty # GPU terminal emulator
     kitty-themes # Kitty color scheme collection
-    wofi # Wayland app launcher (dmenu-like)
-    waybar # Wayland status bar
     wlogout # logout menu for Wayland
-    swaylock-effects # screen locker (blur/FX support)
     swaynotificationcenter # notification daemon UI
+    btop # resource monitor (CPU/RAM/etc.)
     pavucontrol # audio volume control GUI
     impala # network TUI
 
@@ -62,7 +59,6 @@
     swappy # screenshot annotation tool
     wf-recorder # screen recording tool (Wayland)
     hyprpaper # wallpaper daemon for Hyprland
-    hyprlock # lock screen for Hyprland
     gamescope # gaming compositor (Steam/Proton use)
 
     # file management / navigation
diff --git a/home/scripts.nix b/user/scripts.nix
similarity index 100%
rename from home/scripts.nix
rename to user/scripts.nix
