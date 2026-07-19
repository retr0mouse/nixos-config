{
  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";

    extraConfig = builtins.readFile ./config.lua;
  };
}
