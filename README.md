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
diff --git a/home/home.nix b/home/home.nix
deleted file mode 100644
index da94b06..0000000
--- a/home/home.nix
+++ /dev/null
@@ -1,169 +0,0 @@
-{
-  config,
-  pkgs,
-  lib,
-  user,
-  ...
-}: {
-  imports = [
-    ./modules/hyprland.nix
-    ./modules/waybar.nix
-    ./modules/kitty.nix
-    ./modules/neovim.nix
-    ./modules/brave.nix
-    ./modules/git.nix
-    ./programs.nix
-    ./scripts.nix
-  ];
-
-  services.hyprpolkitagent.enable = true;
-
-  home = {
-    username = user;
-    homeDirectory = "/home/${user}";
-  };
-
-  home.stateVersion = "24.11"; # Please read the comment before changing.
-
-  home.packages = [
-    pkgs.hyprlock
-  ];
-  wayland.windowManager.hyprland.systemd.enable = false;
-  gtk = {
-    enable = true;
-    iconTheme = {
-      name = "Papirus-Dark";
-      package = pkgs.papirus-icon-theme;
-    };
-  };
-
-  programs.ssh = {
-    enable = true;
-  };
-
-  home.pointerCursor = {
-    gtk.enable = true;
-    x11.enable = true;
-    package = pkgs.bibata-cursors;
-    name = "Bibata-Modern-Classic";
-    size = 24;
-  };
-
-  home.file = {
-  };
-
-  programs.rofi = {
-    enable = true;
-  };
-
-  programs.hyprlock = {
-    enable = true;
-    settings = {
-      general = {
-        hide_cursor = false;
-        ignore_empty_input = true;
-      };
-
-      animations = {
-        enabled = true;
-        fade_in = {
-          duration = 300;
-          bezier = "easeOutQuint";
-        };
-        fade_out = {
-          duration = 300;
-          bezier = "easeOutQuint";
-        };
-      };
-
-      background = [
-        {
-          path = "screenshot";
-          blur_passes = 3;
-          blur_size = 8;
-        }
-      ];
-
-      input-field = [
-        {
-          size = "200, 50";
-          position = "0, -80";
-          monitor = "";
-          dots_center = true;
-          fade_on_empty = false;
-          font_color = "rgb(202, 211, 245)";
-          inner_color = "rgb(91, 96, 120)";
-          outer_color = "rgb(24, 25, 38)";
-          outline_thickness = 5;
-          shadow_passes = 2;
-        }
-      ];
-      label = [
-        {
-          monitor = "";
-          text = "$LAYOUT"; # current layout
-          font_size = 12;
-          font_color = "rgb(202, 211, 245)";
-          position = "0, -200"; # adjust vertical position
-          halign = "center";
-          valign = "center";
-        }
-        {
-          monitor = "";
-          text = "$TIME"; # 24h format
-          font_size = 44;
-          font_color = "rgb(202, 211, 245)";
-          position = "0, 100"; # adjust position below
-          halign = "center";
-          valign = "center";
-        }
-      ];
-    };
-  };
-
-  # zsh
-  programs.zsh = {
-    enable = true;
-    enableCompletion = true;
-    syntaxHighlighting.enable = true;
-
-    shellAliases = {
-      config = "cd ~/dots && tree";
-      rebuild = "sudo nixos-rebuild switch --flake ~/dots#msi-server";
-      logthefuckout = "loginctl terminate-user $USER";
-      slip = "hyprlock & systemctl suspend";
-    };
-    oh-my-zsh = {
-      enable = true;
-      plugins = ["git"];
-      theme = "robbyrussell";
-    };
-  };
-
-  # Default apps
-  xdg.mimeApps = {
-    enable = true;
-
-    defaultApplications = {
-      "text/html" = "brave.desktop";
-      "x-scheme-handler/http" = "brave.desktop";
-      "x-scheme-handler/https" = "brave.desktop";
-      "x-scheme-handler/about" = "brave.desktop";
-      "x-scheme-handler/unknown" = "brave.desktop";
-    };
-  };
-
-  home.sessionVariables = {
-    NIXOS_OZONE_WL = "1"; # Force Wayland for electron apps
-
-    #Wayland support for specific apps
-    MOZ_ENABLE_WAYLAND = "1";
-    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
-
-    #For Anki
-    ANKI_WAYLAND = "1";
-  };
-
-  # Let Home Manager install and manage itself.
-  programs.home-manager.enable = true;
-}
diff --git a/home/modules/brave.nix b/home/modules/brave.nix
deleted file mode 100644
index e85f698..0000000
--- a/home/modules/brave.nix
+++ /dev/null
@@ -1,8 +0,0 @@
-{
-  programs.brave = {
-    enable = true;
-    commandLineArgs = [
-      "--password-store=basic"
-    ];
-  };
-}
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
diff --git a/home/modules/hyprland.nix b/home/modules/hyprland.nix
deleted file mode 100644
index 70412bd..0000000
--- a/home/modules/hyprland.nix
+++ /dev/null
@@ -1,172 +0,0 @@
-{
-  wayland.windowManager.hyprland = {
-    enable = true;
-
-    extraConfig = ''
-      $terminal = kitty
-      $menu = rofi -show drun
-      $browser = brave
-
-      # Config for the displays
-      source = ~/.config/hypr/monitors.conf
-
-      # Autostart apps
-      exec-once = systemctl --user start waybar.service
-      exec-once = swaync &
-      exec-once = wl-paste --type text --watch cliphist store
-      exec-once = wl-paste --type image --watch cliphist store
-      exec-once = waypaper --restore
-
-      xwayland {
-        force_zero_scaling = true
-      }
-
-      # Enable animations
-      animations {
-        enabled = 1
-      }
-
-      misc {
-        disable_hyprland_logo = true
-        disable_splash_rendering = true
-      }
-
-      # Input config
-      input {
-        kb_layout = ee(us), ru
-        kb_options = grp:ctrl_space_toggle
-        follow_mouse = 2
-
-        touchpad {
-          natural_scroll = yes
-          disable_while_typing = true
-        }
-      }
-
-      # General settings
-      general {
-        gaps_in = 0
-        gaps_out = 0
-        border_size = 0
-        layout = dwindle
-        no_border_on_floating = 1
-        no_focus_fallback = 1
-        col.active_border = rgba(00000000)
-        col.inactive_border = rgba(00000000)
-      }
-
-      decoration {
-        shadow:enabled = false
-        rounding = 0
-      }
-
-      # Dwindle layout
-      dwindle {
-        pseudotile = true
-        preserve_split = true
-      }
-
-      cursor {
-        no_warps = true
-      }
-
-      # Window rules
-      windowrule = pseudo, title:Telegram
-      windowrule = size 500 700, title:Telegram
-      windowrulev2 = workspace 10 silent, title:Telegram
-      windowrulev2 = workspace 10 silent, title:Discord
-      windowrulev2 = workspace 9 silent, title:Steam
-
-      # intellij focus fix
-      windowrulev2 = noinitialfocus, class:^(.*jetbrains.*)$, title:^(win.*)$
-
-      # Move and resize windows with mouse
-      bindm = SUPER, mouse:272, movewindow
-      bindm = SUPER, mouse:273, resizewindow
-
-      # Move windows with keyboard
-      bind = SUPER SHIFT, H, movewindow, l
-      bind = SUPER SHIFT, J, movewindow, d
-      bind = SUPER SHIFT, K, movewindow, u
-      bind = SUPER SHIFT, L, movewindow, r
-
-      # Resize windows using keyboard
-      bind = SUPER, R, submap, resize
-
-      submap = resize
-        bind = , H, resizeactive, -60 0
-        bind = , J, resizeactive, 0 60
-        bind = , K, resizeactive, 0 -60
-        bind = , L, resizeactive, 60 0
-        bind = , left, resizeactive, -60 0
-        bind = , down, resizeactive, 0 60
-        bind = , up, resizeactive, 0 -60
-        bind = , right, resizeactive, 60 0
-        bind = , Return, submap, reset
-        bind = , Escape, submap, reset
-      submap = reset
-
-      # Keybinds
-      bind = SUPER, Return, exec, $terminal
-      bind = SUPER, Space, exec, $menu
-      bind = ,Pause, exec, hyprlock
-      bind = SUPER SHIFT, Return, exec, $browser
-      bind = SUPER SHIFT, Q, killactive,
-      bind = SUPER, E, exec, kitty -e yazi
-      bind = SUPER, V, togglefloating,
-      bind = SUPER, F, fullscreen,
-      bind = SUPER, P, pseudo
-
-      # Move focus
-      bind = SUPER, H, movefocus, l
-      bind = SUPER, L, movefocus, r
-      bind = SUPER, K, movefocus, u
-      bind = SUPER, J, movefocus, d
-
-      # Workspaces
-      bind = SUPER, 1, workspace, 1
-      bind = SUPER, 2, workspace, 2
-      bind = SUPER, 3, workspace, 3
-      bind = SUPER, 4, workspace, 4
-      bind = SUPER, 5, workspace, 5
-      bind = SUPER, 6, workspace, 6
-      bind = SUPER, 7, workspace, 7
-      bind = SUPER, 8, workspace, 8
-      bind = SUPER, 9, workspace, 9
-      bind = SUPER, 0, workspace, 10
-      bind = SUPER, N, togglespecialworkspace
-
-      # Move window to workspace
-      bind = SUPER SHIFT, 1, movetoworkspace, 1
-      bind = SUPER SHIFT, 2, movetoworkspace, 2
-      bind = SUPER SHIFT, 3, movetoworkspace, 3
-      bind = SUPER SHIFT, 4, movetoworkspace, 4
-      bind = SUPER SHIFT, 5, movetoworkspace, 5
-      bind = SUPER SHIFT, 6, movetoworkspace, 6
-      bind = SUPER SHIFT, 7, movetoworkspace, 7
-      bind = SUPER SHIFT, 8, movetoworkspace, 8
-      bind = SUPER SHIFT, 9, movetoworkspace, 9
-      bind = SUPER SHIFT, 0, movetoworkspace, 10
-      bind = SUPER SHIFT, N, movetoworkspace, special
-
-      # Screenshot
-      bind = SUPER SHIFT, S, exec, grim -g "$(slurp)" - | swappy -f -
-
-      # Ignore maximize requests from apps. You'll probably like this.
-      windowrulev2 = suppressevent maximize, class:.*
-
-      # Fix some dragging issues with XWayland
-      windowrulev2 = nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0
-
-      # Laptop multimedia keys for volume and LCD brightness
-      bindel = ,XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
-      bindel = ,XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
-      bindel = ,XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
-      bindel = ,XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
-      bindel = ,XF86MonBrightnessUp, exec, brightnessctl s 10%+
-      bindel = ,XF86MonBrightnessDown, exec, brightnessctl s 10%-
-      bindel = ,XF86KbdBrightnessDown, exec, brightnessctl -d asus::kbd_backlight set 1-
-      bindel = ,XF86KbdBrightnessUp, exec, brightnessctl -d asus::kbd_backlight set 1+
-    '';
-  };
-}
diff --git a/home/modules/kitty.nix b/home/modules/kitty.nix
deleted file mode 100644
index a6622a1..0000000
--- a/home/modules/kitty.nix
+++ /dev/null
@@ -1,35 +0,0 @@
-{
-  programs.kitty = {
-    enable = true;
-    settings = {
-      font_family = "Fira Code";
-      font_size = 12;
-      confirm_os_window_close = 0;
-      enable_audio_bell = false;
-      window_padding_width = 10;
-      cursor_shape = "block";
-      cursor_blink_interval = 0;
-      tab_bar_edge = "top";
-      tab_bar_style = "powerline";
-      tab_powerline_style = "slanted";
-      tab_title_template = "[{index}] {title}";
-    };
-    theme = "Tokyo Night";
-    keybindings = {
-      # Create / close tabs
-      "ctrl+t" = "new_tab";
-      "ctrl+w" = "close_tab";
-
-      # Switch to tab by index (1-based!)
-      "ctrl+1" = "goto_tab 1";
-      "ctrl+2" = "goto_tab 2";
-      "ctrl+3" = "goto_tab 3";
-      "ctrl+4" = "goto_tab 4";
-      "ctrl+5" = "goto_tab 5";
-      "ctrl+6" = "goto_tab 6";
-      "ctrl+7" = "goto_tab 7";
-      "ctrl+8" = "goto_tab 8";
-      "ctrl+9" = "goto_tab 9";
-    };
-  };
-}
diff --git a/home/modules/neovim.nix b/home/modules/neovim.nix
deleted file mode 100644
index 8cb6e2e..0000000
--- a/home/modules/neovim.nix
+++ /dev/null
@@ -1,94 +0,0 @@
-{
-  config,
-  pkgs,
-  ...
-}: {
-  programs.neovim = {
-    enable = true;
-    defaultEditor = true;
-    viAlias = true;
-    vimAlias = true;
-    vimdiffAlias = true;
-
-    plugins = with pkgs.vimPlugins; [
-      conform-nvim
-      nvim-lspconfig
-      nvim-treesitter.withAllGrammars
-      plenary-nvim
-      mini-nvim
-      yazi-nvim
-      kanagawa-nvim
-      tokyonight-nvim
-    ];
-
-    extraConfig = ''
-      set termguicolors
-      colorscheme tokyonight-night
-    '';
-
-    extraLuaConfig = ''
-      vim.g.mapleader = " "
-      vim.opt.number = true
-      vim.opt.relativenumber = true
-      vim.opt.shiftwidth = 4
-      vim.opt.tabstop = 4
-      vim.opt.expandtab = true
-      vim.opt.shiftwidth = 4
-      vim.opt.tabstop = 4
-      vim.opt.expandtab = true
-      vim.opt.clipboard = "unnamedplus"
-
-      vim.api.nvim_create_autocmd("FileType", {
-        pattern = "nix",
-        callback = function()
-          vim.opt_local.shiftwidth = 2
-          vim.opt_local.tabstop = 2
-          vim.opt_local.expandtab = true
-        end,
-      })
-      vim.opt.list = true
-      vim.opt.cursorline = true
-      vim.opt.scrolloff = 8
-
-      -- yazi
-      vim.keymap.set("n", "<leader>-", function()
-        require("yazi").yazi()
-      end)
-
-      vim.g.loaded_netrwPlugin = 1
-
-      vim.api.nvim_create_autocmd("UIEnter", {
-        callback = function()
-          require("yazi").setup({
-            open_for_directories = true,
-          })
-        end,
-      })
-
-      -- conform.nvim
-      require("conform").setup({
-        formatters_by_ft = {
-          nix = { "alejandra" },
-          lua = { "stylua" },
-          python = { "black" },
-          javascript = { "prettier" },
-          typescript = { "prettier" },
-          json = { "prettier" },
-        },
-
-        format_on_save = {
-          timeout_ms = 500,
-          lsp_fallback = true,
-        },
-      })
-
-      -- manual format
-      vim.keymap.set("n", "<leader>f", function()
-        require("conform").format({
-          async = true,
-          lsp_fallback = true,
-        })
-      end)
-    '';
-  };
-}
diff --git a/home/modules/waybar.nix b/home/modules/waybar.nix
deleted file mode 100644
index 5866a13..0000000
--- a/home/modules/waybar.nix
+++ /dev/null
@@ -1,341 +0,0 @@
-{
-  config,
-  lib,
-  pkgs,
-  ...
-}: {
-  programs.waybar = {
-    enable = true;
-
-    settings = [
-      {
-        modules-left = [
-          "group/workspaces"
-          "group/brightvol"
-        ];
-
-        modules-center = [
-          "custom/openbracket"
-          "clock"
-          "custom/closebracket"
-        ];
-
-        modules-right = [
-          "group/performance"
-          "group/system"
-        ];
-
-        "custom/openbracket" = {
-          format = "[";
-          tooltip = false;
-        };
-
-        "custom/closebracket" = {
-          format = "]";
-          tooltip = false;
-        };
-
-        "custom/split" = {
-          format = "|";
-          tooltip = false;
-        };
-
-        "custom/powerprofile" = {
-          exec = "powerprofile display";
-          on-click = "powerprofile toggle";
-          interval = 5;
-          tooltip = true;
-          exec-tooltip = "powerprofile tooltip";
-        };
-
-        "group/workspaces" = {
-          orientation = "horizontal";
-          modules = [
-            "custom/openbracket"
-            "hyprland/workspaces"
-            "custom/closebracket"
-          ];
-        };
-
-        "hyprland/workspaces" = {
-          all-outputs = true;
-          warp-on-scroll = false;
-          enable-bar-scroll = true;
-          disable-scroll-wraparound = true;
-          active-only = false;
-          format = "{icon}";
-        };
-
-        "group/performance" = {
-          orientation = "horizontal";
-          modules = [
-            "custom/openbracket"
-            "cpu"
-            "custom/split"
-            "memory"
-            "custom/closebracket"
-          ];
-        };
-
-        cpu = {
-          format = "CPU:{usage}%";
-          tooltip = false;
-          interval = 2;
-          on-click = "kitty -e btop";
-        };
-
-        memory = {
-          format = "RAM:{}%";
-          tooltip = false;
-          interval = 2;
-          on-click = "kitty -e btop";
-        };
-
-        "custom/igpu" = {
-          exec = "igpu_usage";
-          interval = 2;
-          format = "iGPU{}";
-          on-click = "kitty -e nvidia-smi";
-        };
-
-        "custom/dgpu" = {
-          exec = "dgpu_usage";
-          interval = 2;
-          format = "dGPU:{}";
-          on-click = "kitty -e nvidia-smi";
-        };
-
-        "group/brightvol" = {
-          orientation = "horizontal";
-          modules = [
-            "custom/openbracket"
-            "backlight"
-            "custom/split"
-            "pulseaudio"
-            "custom/closebracket"
-          ];
-        };
-
-        pulseaudio = {
-          scroll-step = 5;
-          format = "{icon} {volume}%";
-          format-muted = "󰝟";
-          format-icons = {
-            headphone = "";
-            hands-free = "";
-            headset = "";
-            phone = "";
-            portable = "";
-            car = "";
-            default = ["" "" ""];
-          };
-          on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
-          on-click-right = "pavucontrol";
-        };
-
-        backlight = {
-          format = "{icon} {percent}%";
-          format-icons = ["🌙" "" ""];
-        };
-
-        "group/system" = {
-          orientation = "horizontal";
-          modules = [
-            "custom/openbracket"
-            "network"
-            "custom/split"
-            "custom/bluetooth"
-            "custom/split"
-            "battery"
-            "custom/split"
-            "custom/swaync"
-            "custom/closebracket"
-          ];
-        };
-
-        clock = {
-          format = "{:%H:%M}";
-          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
-        };
-
-        battery = {
-          states = {
-            warning = 30;
-            critical = 15;
-          };
-          format = "{icon} {capacity}%";
-          format-full = "{icon} {capacity}%";
-          format-charging = " {capacity}%";
-          format-plugged = " {capacity}%";
-          format-icons = ["" "" "" "" ""];
-          on-click = "wlogout";
-        };
-
-        "custom/swaync" = {
-          format = "";
-          exec = "swaync-client -swb";
-          on-click = "swaync-client --toggle-panel";
-          interval = 0;
-        };
-
-        network = {
-          interface = "wlan0";
-          format-wifi = "{icon}";
-          format-ethernet = "󰈀 LAN";
-          format-disconnected = "󰖪";
-          tooltip-format = "{ipaddr}\n{essid} ({signalStrength}%)";
-          on-click = "kitty -e impala";
-          format-icons = ["󰤯" "󰤟" "󰤢" "󰤥" "󰤨"];
-        };
-
-        "custom/bluetooth" = {
-          format = "{}";
-          exec = "bluetooth_status";
-          interval = 5;
-          on-click = "kitty -e bluetui";
-        };
-      }
-    ];
-
-    style = ''
-      /* colors defined at top for easy configuring */
-      @define-color background #2C2A24;
-      @define-color second-background #3A372F;
-      @define-color text #DDD5C4;
-      @define-color borders #A0907A;
-      @define-color focused #D08B57;
-      @define-color focused2 #BFAA80;
-      @define-color color1 #7699A3;
-      @define-color color2 #8D7AAE;
-      @define-color color3 #78997A;
-      @define-color urgent #B05A5A;
-
-
-      /* font declared */
-      * {
-        font-family: "Iosevka";
-        font-size: 15px;
-      }
-
-      /* idk what all this does */
-      window#waybar {
-        background-color: @background;
-        border-bottom: 0;
-        color: @text;
-        transition: background-color 0.5s;
-      }
-
-      window#waybar.hidden {
-        opacity: 0.2;
-      }
-
-      window#waybar.empty #window {
-        background-color: transparent;
-      }
-
-      #custom-openbracket,
-      #custom-closebracket,
-      #custom-split {
-        margin: 0 5px;
-      }
-
-      /* whats this?? */
-      button {
-        border: none;
-      }
-
-
-      /* left island */
-
-      #custom-arch:hover {
-        color: @color1;
-      }
-
-      #custom-powerprofile:hover {
-        color: @color1
-      }
-
-      #custom-themeswitcher:hover {
-        color: @color1;
-      }
-
-      /* workspace pannel */
-      #workspaces button {
-        min-width: 0;
-        background-color: transparent;
-        color: @text;
-        border-radius: 0;
-      }
-
-      #workspaces button:hover {
-        background-color: @second-background;
-      }
-
-      #workspaces button.active {
-        color: @focused2;
-        background-color: @second-background;
-      }
-
-      #workspaces button.urgent {
-        background-color: @urgent;
-      }
-
-      /* no idea what this does */
-      .modules-left>widget:first-child>#workspaces {
-        margin-left: 0;
-      }
-
-      .modules-right>widget:last-child>#workspaces {
-        margin-right: 0;
-      }
-
-      /* Right Island */
-
-      #clock:hover,
-      #battery:hover,
-      #custom-cpu:hover,
-      #custom-clipboard:hover,
-      #custom-bluetooth:hover,
-      #network:hover,
-      #idle_inhibitor:hover,
-      #custom-swaync:hover,
-      #backlight:hover,
-      #wireplumber:hover {
-        color: @color1;
-      }
-
-      #wireplumber.muted {
-        background-color: @color2;
-      }
-
-      #custom-swaync {
-        font-size: 16px;
-        /* same scale as other icons */
-        color: @text;
-      }
-
-      #battery {
-        padding: 0 5px;
-      }
-
-      #battery.charging,
-      #battery.plugged {
-        background-color: @focused2 ;
-        color: @background;
-      }
-
-      #battery.critical:not(.charging) {
-        background-color: @urgent;
-        color: @text;
-        animation: blink 0.5s steps(12) infinite alternate;
-      }
-
-      @keyframes blink {
-        to {
-          background-color: @second-background;
-          color: @text;
-        }
-      }
-    '';
-  };
-}
diff --git a/home/programs.nix b/home/programs.nix
deleted file mode 100644
index 50d4c11..0000000
--- a/home/programs.nix
+++ /dev/null
@@ -1,99 +0,0 @@
-{pkgs, ...}: {
-  home.packages = with pkgs; [
-    # formatters / linters
-    alejandra # Nix formatter
-    stylua # Lua formatter (Neovim configs, etc.)
-    black # Python formatter
-    nodePackages.prettier # JS/TS/JSON formatter
-
-    # core runtimes / CLI utilities
-    python310 # Python interpreter
-    jq # JSON processor (CLI)
-    nodejs_24 # JavaScript runtime (Node.js)
-    gcc # C/C++ compiler toolchain
-    dotnetCorePackages.sdk_9_0_1xx # dotnet 9.0.1 SDK
-
-    # terminal / UI apps
-    kitty # GPU terminal emulator
-    kitty-themes # Kitty color scheme collection
-    wofi # Wayland app launcher (dmenu-like)
-    waybar # Wayland status bar
-    wlogout # logout menu for Wayland
-    swaylock-effects # screen locker (blur/FX support)
-    swaynotificationcenter # notification daemon UI
-    pavucontrol # audio volume control GUI
-    impala # network TUI
-
-    # desktop / communication apps
-    discord # chat/voice platform
-    telegram-desktop # Telegram messenger
-    spotify # music streaming client
-    obsidian # markdown note-taking app
-    anki-bin # spaced repetition flashcards
-    obs-studio # streaming/recording software
-    qbittorrent # torrent client
-
-    # browsing / internet tools
-    chromium # open-source browser
-    chromedriver # automation driver for Chromium
-    insomnia # API testing client (Postman alternative)
-
-    # development tools / IDEs
-    vscode # Visual Studio Code editor
-    jetbrains.idea # IntelliJ IDEA IDE
-    maven # Java build system
-
-    # system utilities
-    gh # GitHub CLI
-    libnotify # desktop notifications CLI (notify-send)
-    playerctl # media control CLI (play/pause etc.)
-    brightnessctl # screen brightness control
-    wl-clipboard # Wayland clipboard tools (wl-copy/paste)
-    cliphist # clipboard history manager
-    tree # directory tree viewer
-    fzf # fuzzy finder in terminal
-    sl # fun terminal animation (train)
-    hollywood # “hacker screen” fake terminal effect
-    unrar # archive utility
-
-    # Wayland graphics / screen tools
-    slurp # region selector (screenshots)
-    grim # screenshot tool for Wayland
-    swappy # screenshot annotation tool
-    wf-recorder # screen recording tool (Wayland)
-    hyprpaper # wallpaper daemon for Hyprland
-    hyprlock # lock screen for Hyprland
-    gamescope # gaming compositor (Steam/Proton use)
-
-    # file management / navigation
-    yazi # terminal file manager
-
-    # office / productivity
-    libreoffice-qt # office suite (documents/spreadsheets/etc.)
-    hunspell # spell checker engine
-    hunspellDicts.ru_RU # Russian dictionary for hunspell
-    hunspellDicts.en-us # English dictionary for hunspell
-    foliate # ebook reader
-
-    # media / creative tools
-    vlc # media player
-    audacity # audio editor
-
-    # gaming / emulation
-    prismlauncher # Minecraft launcher
-
-    # system / hardware utilities
-    nwg-displays # monitor configuration tool (Wayland)
-    bluetui # Bluetooth TUI manager
-
-    # password / identity
-    _1password-gui # password manager
-
-    # digital signature / gov tools
-    qdigidoc # Estonian digital signing tool
-
-    # miscellaneous / experiments
-    matugen # Material You theme generator
-    waypaper # wallpaper picker frontend
-  ];
-}
diff --git a/home/scripts.nix b/home/scripts.nix
deleted file mode 100644
index 1c96780..0000000
--- a/home/scripts.nix
+++ /dev/null
@@ -1,11 +0,0 @@
-{pkgs, ...}: let
-  mkScript = name: pkgs.writeShellScriptBin name (builtins.readFile ../scripts/${name}.sh);
-in {
-  home.packages = [
-    (mkScript "powerprofile")
-    (mkScript "igpu_usage")
-    (mkScript "dgpu_usage")
-    (mkScript "bluetooth_status")
-    (mkScript "clipboard_menu")
-  ];
-}
diff --git a/nixos/hosts/asus/configuration.nix b/nixos/hosts/asus/configuration.nix
deleted file mode 100644
index cffb060..0000000
--- a/nixos/hosts/asus/configuration.nix
+++ /dev/null
@@ -1,54 +0,0 @@
-{
-  config,
-  lib,
-  pkgs,
-  inputs,
-  user,
-  ...
-}: {
-  imports = [
-    ../../modules/desktop.nix
-    ./hardware-configuration.nix
-    inputs.nixos-hardware.nixosModules.asus-zephyrus-ga503
-  ];
-
-  networking.hostName = "ga503";
-
-  services.asusd.enable = true;
-  services.logind.lidSwitchExternalPower = "ignore";
-
-  services.power-profiles-daemon.enable = true;
-
-  services.libinput = {
-    enable = true;
-    touchpad.naturalScrolling = true;
-  };
-
-  services.xserver.enable = true;
-  services.xserver.videoDrivers = ["amdgpu" "nvidia"];
-
-  hardware.nvidia = {
-    modesetting.enable = true;
-    powerManagement.enable = true;
-    powerManagement.finegrained = true;
-
-    open = true;
-    nvidiaSettings = true;
-
-    package = config.boot.kernelPackages.nvidiaPackages.stable;
-
-    prime = {
-      #      amdgpuBusId = "PCI:6:0:0";
-      nvidiaBusId = "PCI:1:0:0";
-
-      offload = {
-        enable = true;
-        enableOffloadCmd = true;
-      };
-    };
-  };
-
-  hardware.graphics.extraPackages = with pkgs; [
-    mesa
-  ];
-}
diff --git a/nixos/hosts/asus/hardware-configuration.nix b/nixos/hosts/asus/hardware-configuration.nix
deleted file mode 100644
index 384690a..0000000
--- a/nixos/hosts/asus/hardware-configuration.nix
+++ /dev/null
@@ -1,33 +0,0 @@
-# Do not modify this file!  It was generated by ‘nixos-generate-config’
-# and may be overwritten by future invocations.  Please make changes
-# to /etc/nixos/configuration.nix instead.
-{ config, lib, pkgs, modulesPath, ... }:
-
-{
-  imports =
-    [ (modulesPath + "/installer/scan/not-detected.nix")
-    ];
-
-  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "usbhid" "usb_storage" "sd_mod" "sdhci_pci" ];
-  boot.initrd.kernelModules = [ ];
-  boot.kernelModules = [ "kvm-amd" ];
-  boot.extraModulePackages = [ ];
-
-  fileSystems."/" =
-    { device = "/dev/disk/by-uuid/26c57f72-0ae8-412e-80df-fe34a3978f72";
-      fsType = "ext4";
-    };
-
-  fileSystems."/boot" =
-    { device = "/dev/disk/by-uuid/2CD1-F3E2";
-      fsType = "vfat";
-      options = [ "fmask=0077" "dmask=0077" ];
-    };
-
-  swapDevices =
-    [ { device = "/dev/disk/by-uuid/32ab49be-fb6d-4622-aa69-1a161529ebc2"; }
-    ];
-
-  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
-  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
-}
diff --git a/nixos/hosts/msi-server/configuration.nix b/nixos/hosts/msi-server/configuration.nix
deleted file mode 100644
index 881c8e1..0000000
--- a/nixos/hosts/msi-server/configuration.nix
+++ /dev/null
@@ -1,73 +0,0 @@
-{
-  config,
-  pkgs,
-  user,
-  ...
-}: {
-  imports = [
-    ../../modules/common.nix
-    ./hardware-configuration.nix
-  ];
-
-  networking.hostName = "nico";
-  networking.networkmanager.enable = true;
-  networking.firewall = {
-    enable = true;
-    allowedTCPPorts = [ 22 53 80 ];
-    allowedUDPPorts = [ 53 ];
-  };
-
-  services.logind = {
-    lidSwitch = "ignore";
-    lidSwitchDocked = "ignore";
-    lidSwitchExternalPower = "ignore";
-  };
-
-  systemd.sleep.extraConfig = ''
-    AllowSuspend=no
-    AllowHibernation=no
-    AllowHybridSleep=no
-  '';
-
-  services.fail2ban.enable = true;
-
-  services.unbound = {
-    enable = true;
-    settings = {
-      server = {
-        interface = [ "127.0.0.1" ];
-        port = 5335;
-        hide-identity = true;
-        hide-version = true;
-        qname-minimisation = true;
-        prefetch = true;
-      };
-    };
-  };
-
-  services.pihole-web = {
-    enable = true;
-    ports = [ "80" ];
-  };
-
-  services.pihole-ftl = {
-    enable = true;
-    settings = {
-      dns.interface = "0.0.0.0";
-      dns.upstreams = [ "127.0.0.1#5335" ];
-
-      adlists = [
-        "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
-	"https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/pro.txt"
-      ];
-    };
-  };
-
-  services.journald.extraConfig = ''
-    SystemMaxUse=500M
-  '';
-  environment.systemPackages = with pkgs; [
-    kitty.terminfo
-  ];
-  system.stateVersion = "25.11";
-}
diff --git a/nixos/hosts/msi-server/hardware-configuration.nix b/nixos/hosts/msi-server/hardware-configuration.nix
deleted file mode 100644
index 8874661..0000000
--- a/nixos/hosts/msi-server/hardware-configuration.nix
+++ /dev/null
@@ -1,31 +0,0 @@
-# Do not modify this file!  It was generated by ‘nixos-generate-config’
-# and may be overwritten by future invocations.  Please make changes
-# to /etc/nixos/configuration.nix instead.
-{ config, lib, pkgs, modulesPath, ... }:
-
-{
-  imports =
-    [ (modulesPath + "/installer/scan/not-detected.nix")
-    ];
-
-  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "sd_mod" "rtsx_usb_sdmmc" ];
-  boot.initrd.kernelModules = [ ];
-  boot.kernelModules = [ "kvm-intel" ];
-  boot.extraModulePackages = [ ];
-
-  fileSystems."/" =
-    { device = "/dev/disk/by-uuid/f39fde2a-4b7d-4e63-89ba-f6bb858d0a51";
-      fsType = "ext4";
-    };
-
-  fileSystems."/boot" =
-    { device = "/dev/disk/by-uuid/BD49-D6F2";
-      fsType = "vfat";
-      options = [ "fmask=0077" "dmask=0077" ];
-    };
-
-  swapDevices = [ ];
-
-  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
-  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
-}
diff --git a/nixos/modules/common.nix b/nixos/modules/common.nix
deleted file mode 100644
index 0330a3d..0000000
--- a/nixos/modules/common.nix
+++ /dev/null
@@ -1,60 +0,0 @@
-{
-  pkgs,
-  user,
-  ...
-}: {
-  # Nix
-  nix.settings.experimental-features = ["nix-command" "flakes"];
-  nixpkgs.config.allowUnfree = true;
-
-  nix.gc = {
-    automatic = true;
-    dates = "weekly";
-    options = "--delete-older-than 3d";
-  };
-
-  # Boot
-  boot.loader.systemd-boot.enable = true;
-  boot.loader.efi.canTouchEfiVariables = true;
-
-  # Time / Locale
-  time.timeZone = "Europe/Tallinn";
-
-  i18n.defaultLocale = "en_CA.UTF-8";
-  i18n.extraLocaleSettings.LC_TIME = "en_GB.UTF-8";
-
-  # Core services
-  services = {
-    dbus.enable = true;
-    fstrim.enable = true;
-    timesyncd.enable = true;
-    openssh = {
-      enable = true;
-      settings.PasswordAuthentication = false;
-    };
-  };
-
-  # User
-  users.users.${user} = {
-    isNormalUser = true;
-    shell = pkgs.zsh;
-    extraGroups = [
-      "wheel"
-      "networkmanager"
-      "docker"
-    ];
-  };
-
-  programs.zsh.enable = true;
-
-  # Docker
-  virtualisation.docker.enable = true;
-
-  # nix-ld
-  programs.nix-ld.enable = true;
-  
-  environment.systemPackages = with pkgs; [
-    git
-    neovim
-  ];
-}
diff --git a/nixos/modules/desktop.nix b/nixos/modules/desktop.nix
deleted file mode 100644
index e335a14..0000000
--- a/nixos/modules/desktop.nix
+++ /dev/null
@@ -1,157 +0,0 @@
-{
-  config,
-  inputs,
-  lib,
-  pkgs,
-  user,
-  ...
-}: {
-  imports = [
-    ./common.nix
-    inputs.xremap-flake.nixosModules.default
-  ];
-
-  # Input / Key remapping
-  services.xremap = {
-    enable = true;
-    serviceMode = "user";
-    withWlroots = true;
-    userName = user;
-
-    config = {
-      virtual_modifiers = ["CapsLock"];
-      keymap = [
-        {
-          remap = {
-            "CapsLock-i" = "Up";
-            "CapsLock-j" = "Left";
-            "CapsLock-k" = "Down";
-            "CapsLock-l" = "Right";
-
-            "CapsLock-m" = "Home";
-            "CapsLock-dot" = "End";
-
-            "CapsLock-u" = "C-Left";
-            "CapsLock-o" = "C-Right";
-          };
-        }
-      ];
-    };
-  };
-
-  # Core desktop services
-  services = {
-    upower.enable = true;
-    pcscd.enable = true;
-    power-profiles-daemon.enable = true;
-    gvfs.enable = true;
-    udisks2.enable = true;
-  };
-
-  security = {
-    polkit.enable = true;
-    rtkit.enable = true;
-  };
-
-  # Spotify LAN sync
-  networking.firewall.allowedTCPPorts = [ 57621 ];
-
-  # Networking (iwd + NetworkManager)
-  networking = {
-    networkmanager.enable = true;
-    networkmanager.wifi.backend = "iwd";
-
-    wireless.iwd = {
-      enable = true;
-      settings.Settings.AutoConnect = true;
-    };
-    dhcpcd.enable = true;
-  };
-
-  systemd.services.NetworkManager-wait-online.enable = false;
-
-  # Boot / splash
-  boot = {
-    plymouth = {
-      enable = true;
-      theme = "breeze";
-    };
-
-    consoleLogLevel = 0;
-    initrd.verbose = false;
-
-    kernelParams = [
-      "quiet"
-      "splash"
-      "boot.shell_on_fail"
-      "loglevel=3"
-      "rd.systemd.show_status=false"
-      "rd.udev.log_level=3"
-      "udev.log_priority=3"
-    ];
-  };
-
-  # Display Manager
-  services.displayManager.ly.enable = true;
-
-  programs = {
-    xwayland.enable = true;
-    hyprland.enable = true;
-
-    steam = {
-      enable = true;
-      remotePlay.openFirewall = true;
-      dedicatedServer.openFirewall = true;
-    };
-
-    gamescope.enable = true
-  };
-
-  # Bluetooth
-  hardware.bluetooth.enable = true;
-  hardware.bluetooth.powerOnBoot = true;
-
-  # Audio
-  services.pipewire = {
-    enable = true;
-    alsa.enable = true;
-    alsa.support32Bit = true;
-    pulse.enable = true;
-    wireplumber.enable = true;
-  };
-
-  # Fonts
-  fonts.packages = with pkgs; [
-    jetbrains-mono
-    font-awesome
-    fira-code
-    material-design-icons
-    fantasque-sans-mono
-    ubuntu-sans
-    iosevka
-  ];
-
-  # Keyboard layout (X11 fallback)
-  services.xserver.xkb = {
-    layout = "ee,ru";
-    options = "grp:ctrl_space_toggle";
-  };
-
-  # XDG portals
-  xdg.portal = {
-    enable = true;
-    extraPortals = with pkgs; [
-      xdg-desktop-portal-gtk
-      xdg-desktop-portal-hyprland
-    ];
-  };
-
-  # User
-  users.users.${user}.extraGroups = lib.mkAfter [
-    "input"
-    "video"
-    "render"
-    "network"
-    "postgres"
-  ];
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
