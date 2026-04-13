{
  programs.kitty = {
    enable = true;
    settings = {
	font_family = "Fira Code";
	font_size = 12;
	confirm_os_window_close = 0;
	enable_audio_bell = false;
	window_padding_width = 10;
	cursor_shape = "block";
	cursor_blink_interval = 0;
	tab_bar_edge = "top";
	tab_bar_style = "powerline";
	tab_powerline_style = "slanted";
	tab_title_template = "[{index}] {title}";
    };
    theme = "Alabaster Dark";
    keybindings = {
      # Create / close tabs
      "ctrl+t" = "new_tab";
      "ctrl+w" = "close_tab";

      # Switch to tab by index (0-based!)
      "ctrl+1" = "goto_tab 1";
      "ctrl+2" = "goto_tab 2";
      "ctrl+3" = "goto_tab 3";
      "ctrl+4" = "goto_tab 4";
      "ctrl+5" = "goto_tab 5";
      "ctrl+6" = "goto_tab 6";
      "ctrl+7" = "goto_tab 7";
      "ctrl+8" = "goto_tab 8";
      "ctrl+9" = "goto_tab 9";
    };
  };
}
