{ config, pkgs, ...}:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    plugins = with pkgs.vimPlugins; [
      nvim-lspconfig
      nvim-treesitter.withAllGrammars
      plenary-nvim
      mini-nvim
      yazi-nvim
      kanagawa-nvim
    ];
    extraConfig = ''
      set termguicolors
      colorscheme kanagawa
      '';
    extraLuaConfig = ''
    vim.g.mapleader = " "

    -- (Obtain yazi.nvim and its dependencies using your preferred method first)
    --
    -- Next, map a key to open yazi.nvim
    vim.keymap.set("n", "<leader>-", function()
      require("yazi").yazi()
    end)

    -- 👇 if you use `open_for_directories=true`, this is recommended.
    --
    -- mark netrw as loaded so it's not loaded at all.
    -- More details: https://github.com/mikavilpas/yazi.nvim/issues/802
    vim.g.loaded_netrwPlugin = 1
    vim.api.nvim_create_autocmd("UIEnter", {
      callback = function()
        require("yazi").setup({
          open_for_directories = true,
        })
      end,
    })
    '';
  };
}
