-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set({ "i" }, "jk", "<ESC>", { noremap = true, desc = "Exit Insert mode", silent = true })

-- Terminal mode fix
vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })
