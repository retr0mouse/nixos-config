{pkgs, ...}: {
  home.packages = with pkgs; [
    # formatters / linters
    alejandra # Nix formatter
    stylua # Lua formatter (Neovim configs, etc.)
    black # Python formatter
    nodePackages.prettier # JS/TS/JSON formatter

    # core runtimes / CLI utilities
    python310 # Python interpreter
    jq # JSON processor (CLI)
    nodejs_24 # JavaScript runtime (Node.js)
    gcc # C/C++ compiler toolchain
    dotnetCorePackages.sdk_9_0_1xx # dotnet 9.0.1 SDK

    # terminal / UI apps
    kitty # GPU terminal emulator
    kitty-themes # Kitty color scheme collection
    wofi # Wayland app launcher (dmenu-like)
    waybar # Wayland status bar
    wlogout # logout menu for Wayland
    swaylock-effects # screen locker (blur/FX support)
    swaynotificationcenter # notification daemon UI
    pavucontrol # audio volume control GUI
    impala # network TUI

    # desktop / communication apps
    discord # chat/voice platform
    telegram-desktop # Telegram messenger
    spotify # music streaming client
    obsidian # markdown note-taking app
    anki-bin # spaced repetition flashcards
    obs-studio # streaming/recording software
    qbittorrent # torrent client

    # browsing / internet tools
    chromium # open-source browser
    chromedriver # automation driver for Chromium
    insomnia # API testing client (Postman alternative)

    # development tools / IDEs
    vscode # Visual Studio Code editor
    jetbrains.idea # IntelliJ IDEA IDE
    maven # Java build system

    # system utilities
    git # version control system
    gh # GitHub CLI
    libnotify # desktop notifications CLI (notify-send)
    playerctl # media control CLI (play/pause etc.)
    brightnessctl # screen brightness control
    wl-clipboard # Wayland clipboard tools (wl-copy/paste)
    cliphist # clipboard history manager
    tree # directory tree viewer
    fzf # fuzzy finder in terminal
    sl # fun terminal animation (train)
    hollywood # “hacker screen” fake terminal effect
    unrar # archive utility

    # Wayland graphics / screen tools
    slurp # region selector (screenshots)
    grim # screenshot tool for Wayland
    swappy # screenshot annotation tool
    wf-recorder # screen recording tool (Wayland)
    hyprpaper # wallpaper daemon for Hyprland
    hyprlock # lock screen for Hyprland
    gamescope # gaming compositor (Steam/Proton use)

    # file management / navigation
    yazi # terminal file manager

    # office / productivity
    libreoffice-qt # office suite (documents/spreadsheets/etc.)
    hunspell # spell checker engine
    hunspellDicts.ru_RU # Russian dictionary for hunspell
    hunspellDicts.en-us # English dictionary for hunspell
    foliate # ebook reader

    # media / creative tools
    vlc # media player
    audacity # audio editor

    # gaming / emulation
    prismlauncher # Minecraft launcher

    # system / hardware utilities
    nwg-displays # monitor configuration tool (Wayland)
    bluetui # Bluetooth TUI manager

    # password / identity
    _1password-gui # password manager

    # digital signature / gov tools
    qdigidoc # Estonian digital signing tool

    # miscellaneous / experiments
    matugen # Material You theme generator
    waypaper # wallpaper picker frontend
  ];
}
