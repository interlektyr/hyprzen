return {
  -- add gruvbox
  { "ellisonleao/gruvbox.nvim" },

  -- Configure LazyVim to load gruvbox
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox",
    },
  },

  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function()
      return {
        sections = {
          lualine_a = { "" },
          lualine_b = { "" },
          lualine_c = { "" },
          lualine_x = { "" },
          lualine_y = { "" },
          lualine_z = { "mode" },
        },
      }
    end,
  },
}
