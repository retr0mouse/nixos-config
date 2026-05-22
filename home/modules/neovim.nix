{
  config,
  pkgs,
  ...
}: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    plugins = with pkgs.vimPlugins; [
      conform-nvim
      nvim-lspconfig
      nvim-treesitter.withAllGrammars
      plenary-nvim
      mini-nvim
      yazi-nvim
      kanagawa-nvim
      tokyonight-nvim
    ];

    extraConfig = ''
      set termguicolors
      colorscheme tokyonight-night
    '';

    extraLuaConfig = ''
      vim.g.mapleader = " "
      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.opt.shiftwidth = 4
      vim.opt.tabstop = 4
      vim.opt.expandtab = true
      vim.opt.shiftwidth = 4
      vim.opt.tabstop = 4
      vim.opt.expandtab = true
      vim.opt.clipboard = "unnamedplus"

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "nix",
        callback = function()
          vim.opt_local.shiftwidth = 2
          vim.opt_local.tabstop = 2
          vim.opt_local.expandtab = true
        end,
      })
      vim.opt.list = true
      vim.opt.cursorline = true
      vim.opt.scrolloff = 8

      -- yazi
      vim.keymap.set("n", "<leader>-", function()
        require("yazi").yazi()
      end)

      vim.g.loaded_netrwPlugin = 1

      vim.api.nvim_create_autocmd("UIEnter", {
        callback = function()
          require("yazi").setup({
            open_for_directories = true,
          })
        end,
      })

      -- conform.nvim
      require("conform").setup({
        formatters_by_ft = {
          nix = { "alejandra" },
          lua = { "stylua" },
          python = { "black" },
          javascript = { "prettier" },
          typescript = { "prettier" },
          json = { "prettier" },
        },

        format_on_save = {
          timeout_ms = 500,
          lsp_fallback = true,
        },
      })

      -- manual format
      vim.keymap.set("n", "<leader>f", function()
        require("conform").format({
          async = true,
          lsp_fallback = true,
        })
      end)
    '';
  };
}
