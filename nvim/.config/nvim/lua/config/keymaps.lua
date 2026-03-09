-- Keymaps
local opts = { noremap = true, silent = true }
local map = vim.keymap.set

----------------------------------------------------
-- INSERT MODE
----------------------------------------------------
map("i", "jk", "<Esc>", { desc = "Exit insert mode" })

----------------------------------------------------
-- BASIC EDITING
----------------------------------------------------
map("n", "<C-d>", "<C-d>zz", { desc = "Half page down centered" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half page up centered" })
map("n", "n", "nzzzv", { desc = "Next search centered" })
map("n", "N", "Nzzzv", { desc = "Prev search centered" })

map("x", "<", "<gv", opts)
map("x", ">", ">gv", opts)

----------------------------------------------------
-- REGISTER SAFE OPERATIONS
----------------------------------------------------
map({ "n", "v" }, "<leader>d", '"_d', { desc = "Delete without yank" })
map("x", "<leader>p", '"_dP', { desc = "Paste without replacing yank" })

----------------------------------------------------
-- SEARCH
----------------------------------------------------
-- Better clear highlight
map("n", "<Esc>", function()
  vim.cmd("nohlsearch")
end, { desc = "Clear search highlight" })

----------------------------------------------------
-- WINDOW NAVIGATION
----------------------------------------------------
map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

----------------------------------------------------
-- WINDOW MANAGEMENT
----------------------------------------------------
map("n", "<leader>wv", "<C-w>v", { desc = "Vertical split" })
map("n", "<leader>wh", "<C-w>s", { desc = "Horizontal split" })
map("n", "<leader>we", "<C-w>=", { desc = "Equalize splits" })
map("n", "<leader>wx", "<cmd>close<CR>", { desc = "Close window" })

----------------------------------------------------
-- WINDOW RESIZING
----------------------------------------------------
map("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Increase window height" })
map("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Decrease window height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Increase window width" })

----------------------------------------------------
-- MOVE LINES
----------------------------------------------------
map("n", "<A-j>", "<cmd>m .+1<CR>==", { desc = "Move line down" })
map("n", "<A-k>", "<cmd>m .-2<CR>==", { desc = "Move line up" })
map("i", "<A-j>", "<Esc><cmd>m .+1<CR>==gi", { desc = "Move line down" })
map("i", "<A-k>", "<Esc><cmd>m .-2<CR>==gi", { desc = "Move line up" })
map("x", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("x", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

----------------------------------------------------
-- TABS
----------------------------------------------------
map("n", "<leader><tab>n", "<cmd>tabnew<CR>", { desc = "New tab" })
map("n", "<leader><tab>x", "<cmd>tabclose<CR>", { desc = "Close tab" })
map("n", "<leader><tab>o", "<cmd>tabonly<CR>", { desc = "Close other tabs" })
map("n", "<leader><tab>]", "<cmd>tabnext<CR>", { desc = "Next tab" })
map("n", "<leader><tab>[", "<cmd>tabprevious<CR>", { desc = "Previous tab" })

-- Numeric tab switching
for i = 1, 9 do
  map("n", "<leader><tab>" .. i, i .. "gt", { desc = "Go to tab " .. i })
end

----------------------------------------------------
-- FILE UTILITIES
----------------------------------------------------
map("n", "<leader>fp", function()
  local path = vim.fn.expand("%:~")
  vim.fn.setreg("+", path)
  print("Copied: " .. path)
end, { desc = "Copy file path" })

----------------------------------------------------
-- DIAGNOSTICS
----------------------------------------------------
map("n", "]d", function()
  vim.diagnostic.jump({ count = 1 })
end, { desc = "Next diagnostic" })

map("n", "[d", function()
  vim.diagnostic.jump({ count = -1 })
end, { desc = "Previous diagnostic" })

map("n", "]e", function()
  vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR })
end, { desc = "Next error" })

map("n", "[e", function()
  vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR })
end, { desc = "Previous error" })

map("n", "]w", function()
  vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.WARN })
end, { desc = "Next warning" })

map("n", "[w", function()
  vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.WARN })
end, { desc = "Previous warning" })

----------------------------------------------------
-- QUICKFIX
----------------------------------------------------
map("n", "]q", "<cmd>cnext<CR>", { desc = "Next quickfix" })
map("n", "[q", "<cmd>cprev<CR>", { desc = "Prev quickfix" })
