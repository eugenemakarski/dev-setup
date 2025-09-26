return {
  "phaazon/hop.nvim",
  branch = "v2", -- optional: specify branch if needed
  event = "VeryLazy", -- lazy load the plugin
  config = function()
    require("hop").setup({
      -- your hop configuration here
      keys = "etovxqpdygfblzhckisuran",
      jump_on_sole_occurrence = true,
    })
  end,
  keys = {
    { "<leader>hw", "<cmd>HopWord<cr>", desc = "Hop to word" },
    { "<leader>hl", "<cmd>HopLine<cr>", desc = "Hop to line" },
    { "<leader>hc", "<cmd>HopChar1<cr>", desc = "Hop to character" },
    { "<leader>hp", "<cmd>HopPattern<cr>", desc = "Hop to pattern" },
  },
}
