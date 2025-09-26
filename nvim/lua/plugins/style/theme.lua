return {
  --   "olivercederborg/poimandres.nvim",
  --   opts = {
  --     bold_vert_split = true,
  --     disable_background = true,
  --   },
  -- },
  {
    "folke/tokyonight.nvim",
    enabled = vim.g.vscode == nil,
    opts = {
      style = "moon", -- day, night, moon, storm
      -- transparent = true,
      -- styles = {
      --   sidebars = "transparent",
      --   floats = "transparent",
      -- },
    },
  },
  -- {
  --   "EdenEast/nightfox.nvim",
  --   opts = {
  --     options = {
  --       styles = {
  --         comments = "italic",
  --         keywords = "bold",
  --         types = "italic,bold",
  --       },
  --     },
  --   },
  -- },
  -- {
  --   "catppuccin/nvim",
  --   lazy = false,
  --   name = "catppuccin",
  --   enabled = vim.g.vscode == nil,
  --   opts = {
  --     flavour = "mocha", -- latte, frappe, macchiato, mocha
  --     term_colors = true, -- sets terminal colors (e.g. `g:terminal_color_0`)
  --     -- background = { -- :h background
  --     --   light = "latte",
  --     --   dark = "macchiato",
  --     -- },
  --     transparent_background = vim.g.neovide == nil,
  --   },
  -- },
  -- { "shaunsingh/moonlight.nvim" },
  -- {
  --   "loctvl842/monokai-pro.nvim",
  --   opts = {},
  -- },
  {
    "LazyVim/LazyVim",
    enabled = vim.g.vscode == nil,
    opts = {
      -- colorscheme = "catppuccin",
      -- colorscheme = "monokai-pro",
      colorscheme = "tokyonight",
      -- colorscheme = "nordfox",
      -- colorscheme = "moonlight",
      -- colorscheme = "poimandres",
    },
  },
}
