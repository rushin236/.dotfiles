-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local opts = { noremap = true, silent = true }
local map = vim.keymap.set

-- Insert Exit Map
map("i", "jk", "<Esc>")

-- Move to window using the <ctrl> hjkl keys
map("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
map("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
map("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
map("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window", remap = true })

-- Resize window using <ctrl> arrow keys
map({ "n", "t" }, "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map({ "n", "t" }, "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map({ "n", "t" }, "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map({ "n", "t" }, "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

-- Move Lines in i, n, x mode
map("n", "<A-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down" })
map("n", "<A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
map("x", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down" })
map("x", "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up" })

map("n", "J", "mzJ`z")
map("n", "<C-d>", "<C-d>zz", { desc = "move down in buffer with cursor centered" })
map("n", "<C-u>", "<C-u>zz", { desc = "move up in buffer with cursor centered" })
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

map("x", "<", "<gv", opts)
map("x", ">", ">gv", opts)

map("n", "<ESC>", ":nohl<CR>", { desc = "Clear search hl", silent = true })

-- format without prettier using the built in
map("n", "<leader>cf", vim.lsp.buf.format)

--Stars new tmux session from in here
-- map("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")

-- tabs
map("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Last Tab" })
map("n", "<leader><tab>o", "<cmd>tabonly<cr>", { desc = "Close Other Tabs" })
map("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "First Tab" })
map("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New Tab" })
map("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next Tab" })
map("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close Tab" })
map("n", "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })

--split management
map("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
-- split window vertically
map("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
-- split window horizontally
map("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
-- close current split window
map("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })

-- Copy filepath to the clipboard
map("n", "<leader>fp", function()
  local filePath = vim.fn.expand("%:~") -- Gets the file path relative to the home directory
  vim.fn.setreg("+", filePath) -- Copy the file path to the clipboard register
  print("File path copied to clipboard: " .. filePath) -- Optional: print message to confirm
end, { desc = "Copy file path to clipboard" })

-- Diagnostics
map("n", "]d", function()
  vim.diagnostic.jump({ count = 1 })
end, vim.tbl_extend("force", opts, { desc = "Next Diagnostic" }))

map("n", "[d", function()
  vim.diagnostic.jump({ count = -1 })
end, vim.tbl_extend("force", opts, { desc = "Prev Diagnostic" }))

map("n", "]e", function()
  vim.diagnostic.jump({
    count = 1,
    severity = vim.diagnostic.severity.ERROR,
  })
end, vim.tbl_extend("force", opts, { desc = "Next Error" }))

map("n", "[e", function()
  vim.diagnostic.jump({
    count = -1,
    severity = vim.diagnostic.severity.ERROR,
  })
end, vim.tbl_extend("force", opts, { desc = "Prev Error" }))

map("n", "]w", function()
  vim.diagnostic.jump({
    count = 1,
    severity = vim.diagnostic.severity.WARN,
  })
end, vim.tbl_extend("force", opts, { desc = "Next Warning" }))

map("n", "[w", function()
  vim.diagnostic.jump({
    count = -1,
    severity = vim.diagnostic.severity.WARN,
  })
end, vim.tbl_extend("force", opts, { desc = "Prev Warning" }))

-- Quickfix navigation
map("n", "]q", "<cmd>cnext<CR>", vim.tbl_extend("force", opts, { desc = "Next Quickfix" }))

map("n", "[q", "<cmd>cprev<CR>", vim.tbl_extend("force", opts, { desc = "Prev Quickfix" }))

map("t", "<esc><esc>", "<c-\\><c-n>", { desc = "mode t to n", noremap = true })
