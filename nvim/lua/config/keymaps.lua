-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

--fzf kepmaps
vim.keymap.set("n", "<leader>ff", "<cmd>FzfLua files<CR>")
vim.keymap.set("n", "<leader>fg", "<cmd>FzfLua live_grep<CR>")
vim.keymap.set("n", "<leader>fb", "<cmd>FzfLua buffers<CR>")
vim.keymap.set("n", "<leader>fh", "<cmd>FzfLua help_tags<CR>")
vim.keymap.set("n", "<leader>fc", "<cmd>FzfLua commands<CR>")
vim.keymap.set("n", "<leader>fk", "<cmd>FzfLua keymaps<CR>")
vim.keymap.set("n", "<leader>fo", "<cmd>FzfLua oldfiles<CR>")
vim.keymap.set("n", "<leader>fm", "<cmd>FzfLua marks<CR>")
vim.keymap.set("n", "<leader>fr", "<cmd>FzfLua registers<CR>")
vim.keymap.set("n", "<leader>fs", "<cmd>FzfLua colorschemes<CR>")

-- ZenMode keymap
vim.keymap.set("n", "<leader>z", "<cmd>ZenMode<CR>")
