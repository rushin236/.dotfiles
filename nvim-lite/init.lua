-- ==================================================
-- Title: basic nvim config
-- author: rushin236
-- ==================================================

-- Basic settings
vim.opt.number = true -- Line numbers
vim.opt.relativenumber = true -- Relative line numbers
vim.opt.cursorline = true -- Highlight current line
vim.opt.wrap = false -- Don't wrap lines
vim.opt.scrolloff = 10 -- Keep 10 lines above/below cursor
vim.opt.sidescrolloff = 8 -- Keep 8 columns left/right of cursor

-- Indentation
vim.opt.tabstop = 2 -- Tab width
vim.opt.shiftwidth = 2 -- Indent width
vim.opt.softtabstop = 2 -- Soft tab stop
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.smartindent = true -- Smart auto-indenting
vim.opt.autoindent = true -- Copy indent from current line

-- Search settings
vim.opt.ignorecase = true -- Case insensitive search
vim.opt.smartcase = true -- Case sensitive if uppercase in search
vim.opt.hlsearch = false -- Don't highlight search results
vim.opt.incsearch = true -- Show matches as you type

-- Visual settings
vim.opt.termguicolors = true -- Enable 24-bit colors
vim.opt.signcolumn = "yes" -- Always show sign column
vim.opt.showmatch = true -- Highlight matching brackets
vim.opt.matchtime = 2 -- How long to show matching bracket
vim.opt.cmdheight = 1 -- Command line height
vim.opt.completeopt = "menuone,noinsert,noselect" -- Completion options
vim.opt.showmode = false -- Don't show mode in command line
vim.opt.pumheight = 10 -- Popup menu height
vim.opt.pumblend = 10 -- Popup menu transparency
vim.opt.winblend = 0 -- Floating window transparency
vim.opt.conceallevel = 0 -- Don't hide markup
vim.opt.concealcursor = "" -- Don't hide cursor line markup
vim.opt.lazyredraw = true -- Don't redraw during macros
vim.opt.synmaxcol = 300 -- Syntax highlighting limit
vim.opt.winborder = "rounded"

-- File handling
vim.opt.backup = false -- Don't create backup files
vim.opt.writebackup = false -- Don't create backup before writing
vim.opt.swapfile = false -- Don't create swap files
vim.opt.undofile = true -- Persistent undo
vim.opt.undodir = vim.fn.expand("~/.vim/undodir") -- Undo directory
vim.opt.updatetime = 300 -- Faster completion
vim.opt.timeoutlen = 500 -- Key timeout duration
vim.opt.ttimeoutlen = 0 -- Key code timeout
vim.opt.autoread = true -- Auto reload files changed outside vim
vim.opt.autowrite = false -- Don't auto save

-- Behavior settings
vim.opt.hidden = true -- Allow hidden buffers
vim.opt.errorbells = false -- No error bells
vim.opt.backspace = "indent,eol,start" -- Better backspace behavior
vim.opt.autochdir = false -- Don't auto change directory
vim.opt.iskeyword:append("-") -- Treat dash as part of word
vim.opt.path:append("**") -- include subdirectories in search
vim.opt.selection = "inclusive" -- Selection behavior
vim.opt.mouse = "a" -- Enable mouse support
vim.opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus" -- Use system clipboard
vim.opt.modifiable = true -- Allow buffer modifications
vim.opt.encoding = "UTF-8" -- Set encoding
vim.opt.shortmess:append("c")

-- Cursor settings
vim.opt.guicursor = {
	"n-v-c:block",
	"i:block-blinkon100-blinkoff100-blinkwait100",
	"r:block",
	"o:block",
}

-- Folding settings
vim.opt.foldmethod = "expr" -- Use expression for folding
vim.opt.foldexpr = "nvim_treesitter#foldexpr()" -- Use treesitter for folding
vim.opt.foldlevel = 99 -- Start with all folds open

-- Split behavior
vim.opt.splitbelow = true -- Horizontal splits go below
vim.opt.splitright = true -- Vertical splits go right

-- Key mappings
vim.g.mapleader = " " -- Set leader key to space
vim.g.maplocalleader = " " -- Set local leader key (NEW)

-- Escape keymap
vim.keymap.set("i", "jk", "<esc>", { desc = "Exit insert mode" })

-- Normal mode mappings
vim.keymap.set("n", "<esc>", ":nohlsearch<CR>", { desc = "Clear search highlights" })

-- Y to EOL
vim.keymap.set("n", "Y", "y$", { desc = "Yank to end of line" })

-- Center screen when jumping
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })

-- Better paste behavior
vim.keymap.set("x", "<leader>p", '"_dP', { desc = "Paste without yanking" })

-- Delete without yanking
vim.keymap.set({ "n", "v" }, "<leader>d", '"_d', { desc = "Delete without yanking" })

-- Buffer navigation
vim.keymap.set("n", "<S-l>", ":bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<S-h>", ":bprevious<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "<leader>bd", ":bdelete<CR>", { desc = "Delete buffer" })

-- Better window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Splitting & Resizing
vim.keymap.set("n", "<leader>sv", ":vsplit<CR>", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>sh", ":split<CR>", { desc = "Split window horizontally" })
vim.keymap.set("n", "<leader>sx", ":close<CR>", { desc = "Split Close" })
vim.keymap.set("n", "<C-Up>", ":resize +2<CR>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", ":resize -2<CR>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })

-- Move lines up/down
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Better indenting in visual mode
vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })

-- Quick file navigation
vim.keymap.set("n", "<leader>e", ":Explore<CR>", { desc = "Open file explorer" })
vim.keymap.set("n", "<leader>ff", ":find ", { desc = "Find file" })

-- Better J behavior
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines and keep cursor position" })

-- Quick config editing
vim.keymap.set("n", "<leader>rc", ":e $MYVIMRC<CR>", { desc = "Edit config" })
vim.keymap.set("n", "<leader>rl", ":so $MYVIMRC<CR>", { desc = "Reload config" })

-- ============================================================================
-- USEFUL FUNCTIONS
-- ============================================================================

-- Copy Full File-Path
vim.keymap.set("n", "<leader>pa", function()
	local path = vim.fn.expand("%:p")
	vim.fn.setreg("+", path)
	print("file:", path)
end)

-- Basic autocommands
local augroup = vim.api.nvim_create_augroup("UserConfig", {})

-- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup,
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Return to last edit position when opening files
vim.api.nvim_create_autocmd("BufReadPost", {
	group = augroup,
	callback = function()
		local mark = vim.api.nvim_buf_get_mark(0, '"')
		local lcount = vim.api.nvim_buf_line_count(0)
		local line = mark[1]
		local ft = vim.bo.filetype
		if
			line > 0
			and line <= lcount
			and vim.fn.index({ "commit", "gitrebase", "xxd" }, ft) == -1
			and not vim.o.diff
		then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- Set filetype-specific settings
-- vim.api.nvim_create_autocmd("FileType", {
--   group = augroup,
--   pattern = { "lua", "python" },
--   callback = function()
--     vim.opt_local.tabstop = 4
--     vim.opt_local.shiftwidth = 4
--   end,
-- })

vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = { "javascript", "typescript", "json", "html", "css" },
	callback = function()
		vim.opt_local.tabstop = 2
		vim.opt_local.shiftwidth = 2
	end,
})

-- Auto-close terminal when process exits
vim.api.nvim_create_autocmd("TermClose", {
	group = augroup,
	callback = function()
		if vim.v.event.status == 0 then
			vim.api.nvim_buf_delete(0, {})
		end
	end,
})

-- Disable line numbers in terminal
vim.api.nvim_create_autocmd("TermOpen", {
	group = augroup,
	callback = function()
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
		vim.opt_local.signcolumn = "no"
	end,
})

-- Auto-resize splits when window is resized
vim.api.nvim_create_autocmd("VimResized", {
	group = augroup,
	callback = function()
		vim.cmd("tabdo wincmd =")
	end,
})

-- Create directories when saving files
vim.api.nvim_create_autocmd("BufWritePre", {
	group = augroup,
	callback = function()
		local dir = vim.fn.expand("<afile>:p:h")
		if vim.fn.isdirectory(dir) == 0 then
			vim.fn.mkdir(dir, "p")
		end
	end,
})

-- Command-line completion
vim.opt.wildmenu = true
vim.opt.wildmode = "longest:full,full"
vim.opt.wildignore:append({ "*.o", "*.obj", "*.pyc", "*.class", "*.jar" })

-- Better diff options
vim.opt.diffopt:append("linematch:60")

-- Performance improvements
vim.opt.redrawtime = 10000
vim.opt.maxmempattern = 20000

-- Create undo directory if it doesn't exist
local undodir = vim.fn.expand("~/.vim/undodir")
if vim.fn.isdirectory(undodir) == 0 then
	vim.fn.mkdir(undodir, "p")
end

-- ============================================================================
-- FLOATING TERMINAL
-- ============================================================================

-- terminal
local terminal_state = {
	buf = nil,
	win = nil,
	is_open = false,
}

local function FloatingTerminal()
	-- If terminal is already open, close it (toggle behavior)
	if terminal_state.is_open and vim.api.nvim_win_is_valid(terminal_state.win) then
		vim.api.nvim_win_close(terminal_state.win, false)
		terminal_state.is_open = false
		return
	end

	-- Create buffer if it doesn't exist or is invalid
	if not terminal_state.buf or not vim.api.nvim_buf_is_valid(terminal_state.buf) then
		terminal_state.buf = vim.api.nvim_create_buf(false, true)
		-- Set buffer options for better terminal experience
		vim.api.nvim_buf_set_option(terminal_state.buf, "bufhidden", "hide")
	end

	-- Calculate window dimensions
	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.8)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	-- Create the floating window
	terminal_state.win = vim.api.nvim_open_win(terminal_state.buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
	})

	-- Set transparency for the floating window
	vim.api.nvim_win_set_option(terminal_state.win, "winblend", 0)

	-- Set transparent background for the window
	vim.api.nvim_win_set_option(
		terminal_state.win,
		"winhighlight",
		"Normal:FloatingTermNormal,FloatBorder:FloatingTermBorder"
	)

	-- Define highlight groups for transparency
	vim.api.nvim_set_hl(0, "FloatingTermNormal", { bg = "none" })
	vim.api.nvim_set_hl(0, "FloatingTermBorder", { bg = "none" })

	-- Start terminal if not already running
	local has_terminal = false
	local lines = vim.api.nvim_buf_get_lines(terminal_state.buf, 0, -1, false)
	for _, line in ipairs(lines) do
		if line ~= "" then
			has_terminal = true
			break
		end
	end

	if not has_terminal then
		vim.fn.termopen(os.getenv("SHELL"))
	end

	terminal_state.is_open = true
	vim.cmd("startinsert")

	-- Set up auto-close on buffer leave
	vim.api.nvim_create_autocmd("BufLeave", {
		buffer = terminal_state.buf,
		callback = function()
			if terminal_state.is_open and vim.api.nvim_win_is_valid(terminal_state.win) then
				vim.api.nvim_win_close(terminal_state.win, false)
				terminal_state.is_open = false
			end
		end,
		once = true,
	})
end

-- Function to explicitly close the terminal
local function CloseFloatingTerminal()
	if terminal_state.is_open and vim.api.nvim_win_is_valid(terminal_state.win) then
		vim.api.nvim_win_close(terminal_state.win, false)
		terminal_state.is_open = false
	end
end

-- Key mappings
vim.keymap.set("n", "<c-\\>", FloatingTerminal, { noremap = true, silent = true, desc = "Toggle floating terminal" })
vim.keymap.set("t", "<c-\\>", function()
	if terminal_state.is_open then
		vim.api.nvim_win_close(terminal_state.win, false)
		terminal_state.is_open = false
	end
end, { noremap = true, silent = true, desc = "Close floating terminal from terminal mode" })

-- ============================================================================
-- TABS
-- ============================================================================

-- Tab display settings
vim.opt.showtabline = 1 -- Always show tabline (0=never, 1=when multiple tabs, 2=always)
vim.opt.tabline = "" -- Use default tabline (empty string uses built-in)

-- Transparent tabline appearance
vim.cmd([[
  hi TabLineFill guibg=NONE ctermfg=242 ctermbg=NONE
]])

-- Clean version: one validation, one error message
local function open_file_in_tab()
	vim.ui.input({
		prompt = "File to open in new tab (empty = current buffer): ",
		completion = "file",
	}, function(input)
		-- Determine the file path: input or current buffer
		local file = nil

		if input and input ~= "" then
			file = vim.fn.fnamemodify(input, ":p")
		else
			file = vim.fn.expand("%:p")
		end

		-- Single validation step
		if file == "" or vim.fn.filereadable(file) == 0 then
			vim.notify("Invalid file: " .. (input or "current buffer"), vim.log.levels.WARN)
			return
		end

		-- Open the file in a new tab
		vim.cmd("tabnew " .. vim.fn.fnameescape(file))

		-- Set tab-local root directory
		local dir = vim.fn.fnamemodify(file, ":h")
		vim.cmd("tcd " .. vim.fn.fnameescape(dir))
	end)
end

-- Keymap: <leader>ot
vim.keymap.set("n", "<leader>tO", open_file_in_tab, { desc = "Open file in new tab" })

-- Alternative navigation (more intuitive)
vim.keymap.set("n", "<leader>to", ":tabnew<CR>", { desc = "New tab" })
vim.keymap.set("n", "<leader>tx", ":tabclose<CR>", { desc = "Close tab" })

-- Tab moving
vim.keymap.set("n", "<leader>tn", ":tabNext<CR>", { desc = "Move to tab right" })
vim.keymap.set("n", "<leader>tp", ":tabprevious<CR>", { desc = "Move to tab left" })
vim.keymap.set("n", "<leader>t]", ":tabmove +1<CR>", { desc = "Move tab right" })
vim.keymap.set("n", "<leader>t[", ":tabmove -1<CR>", { desc = "Move tab left" })

-- ============================================================================
-- STATUSLINE
-- ============================================================================

-- Git branch function
local function git_branch()
	local branch = vim.fn.system("git branch --show-current 2>/dev/null | tr -d '\n'")
	if branch ~= "" then
		return "  " .. branch .. " "
	end
	return ""
end

-- File type with icon
local function file_type()
	local ft = vim.bo.filetype
	local icons = {
		lua = "[LUA]",
		python = "[PY]",
		javascript = "[JS]",
		html = "[HTML]",
		css = "[CSS]",
		json = "[JSON]",
		markdown = "[MD]",
		vim = "[VIM]",
		sh = "[SH]",
	}

	if ft == "" then
		return "  "
	end

	return (icons[ft] or ft)
end

-- Word count for text files
local function word_count()
	local ft = vim.bo.filetype
	if ft == "markdown" or ft == "text" or ft == "tex" then
		local words = vim.fn.wordcount().words
		return "  " .. words .. " words "
	end
	return ""
end

-- File size
local function file_size()
	local size = vim.fn.getfsize(vim.fn.expand("%"))
	if size < 0 then
		return ""
	end
	if size < 1024 then
		return size .. "B "
	elseif size < 1024 * 1024 then
		return string.format("%.1fK", size / 1024)
	else
		return string.format("%.1fM", size / 1024 / 1024)
	end
end

-- Mode indicators with icons
local function mode_icon()
	local mode = vim.fn.mode()
	local modes = {
		n = "NORMAL",
		i = "INSERT",
		v = "VISUAL",
		V = "V-LINE",
		["\22"] = "V-BLOCK", -- Ctrl-V
		c = "COMMAND",
		s = "SELECT",
		S = "S-LINE",
		["\19"] = "S-BLOCK", -- Ctrl-S
		R = "REPLACE",
		r = "REPLACE",
		["!"] = "SHELL",
		t = "TERMINAL",
	}
	return modes[mode] or "  " .. mode:upper()
end

_G.mode_icon = mode_icon
_G.git_branch = git_branch
_G.file_type = file_type
_G.file_size = file_size

vim.cmd([[
  highlight StatusLineBold gui=bold cterm=bold
]])

-- Function to change statusline based on window focus
local function setup_dynamic_statusline()
	vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
		callback = function()
			vim.opt_local.statusline = table.concat({
				"  ",
				"%#StatusLineBold#",
				"%{v:lua.mode_icon()}",
				"%#StatusLine#",
				" │ %f %h%m%r",
				"%{v:lua.git_branch()}",
				" │ ",
				"%{v:lua.file_type()}",
				" | ",
				"%{v:lua.file_size()}",
				"%=", -- Right-align everything after this
				"%l:%c  %P ", -- Line:Column and Percentage
			})
		end,
	})
	vim.api.nvim_set_hl(0, "StatusLineBold", { bold = true })

	vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
		callback = function()
			vim.opt_local.statusline = "  %f %h%m%r │ %{v:lua.file_type()} | %=  %l:%c   %P "
		end,
	})
end

setup_dynamic_statusline()

-----------------------------------------------------------
-- Basic Autocmd
-----------------------------------------------------------

-- Set root dir if dir is passed
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		-- Ensure args is always a table
		local args = vim.fn.argv()
		if type(args) == "string" then
			args = { args }
		end

		-- Find the first directory argument
		for _, arg in ipairs(args) do
			if vim.fn.isdirectory(arg) == 1 then
				vim.cmd("silent! tcd " .. arg)
				break
			end
		end
	end,
})

-----------------------------------------------------------
-- Built-in LSP (NO plugins)
-----------------------------------------------------------

-- LSP
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		local buf = ev.buf
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		local opts = { buffer = buf, silent = true }

		local bufmap = function(mode, lhs, rhs)
			vim.keymap.set(mode, lhs, rhs, opts)
		end

		-- LSP navigation
		bufmap("n", "gd", vim.lsp.buf.definition)
		bufmap("n", "gD", vim.lsp.buf.declaration)
		bufmap("n", "gi", vim.lsp.buf.implementation)
		bufmap("n", "gr", vim.lsp.buf.references)
		bufmap("n", "K", vim.lsp.buf.hover)

		-- LSP actions
		bufmap("n", "<leader>rn", vim.lsp.buf.rename)
		bufmap("n", "<leader>ca", vim.lsp.buf.code_action)
		bufmap({ "n", "v" }, "<leader>f", function()
			vim.lsp.buf.format({ async = true })
		end)

		-- Diagnostics
		bufmap("n", "gl", vim.diagnostic.open_float)
		bufmap("n", "[d", vim.diagnostic.goto_prev)
		bufmap("n", "]d", vim.diagnostic.goto_next)

		-------------------------------------------------------
		-- Enable built-in LSP completion for this client/buffer
		-------------------------------------------------------
		if client and client:supports_method("textDocument/completion") then
			-- good popup behavior
			vim.bo[buf].completeopt = "menu,menuone,noinsert,noselect"

			-- turn on builtin LSP completion with autotrigger
			vim.lsp.completion.enable(true, client.id, buf, {
				autotrigger = true, -- use server triggerCharacters
			})
		end
	end,
})

vim.lsp.enable({
	"lua_ls",
	"bashls",
	"clangd",
	"rust_analyzer",
	"gopls",
	"pyright",
	"ruff",
})

-- ===============================================================================
-- Auto Completion
-- ===============================================================================
-- true if there is at least one LSP client attached to current buffer
local function has_lsp_clients()
	local bufnr = vim.api.nvim_get_current_buf()
	local clients = vim.lsp.get_clients({ bufnr = bufnr })
	return clients and next(clients) ~= nil
end

local function has_word_before()
	local pos = vim.api.nvim_win_get_cursor(0)
	local col = pos[2]
	if col == 0 then
		return false
	end
	local prev_char = vim.api.nvim_get_current_line():sub(col, col)
	return prev_char:match("[%w_]") ~= nil
end

local function trigger_lsp_completion()
	if vim.fn.pumvisible() == 1 then
		return
	end
	if not has_lsp_clients() then
		return
	end
	if not has_word_before() then
		return
	end

	if vim.lsp.completion and vim.lsp.completion.get then
		vim.lsp.completion.get()
	elseif vim.lsp.buf.completion then
		vim.lsp.buf.completion()
	end
end

local function is_path_context()
	local line = vim.api.nvim_get_current_line()
	local pos = vim.api.nvim_win_get_cursor(0)
	local col = pos[2] -- 0-based

	if col == 0 then
		return false
	end

	-- text before cursor (1..col)
	local before = line:sub(1, col)

	-- ─────────────────────────────────────────────
	-- Shebang handling: #!/usr/bin/env, #!/bin/bash, etc.
	-- ─────────────────────────────────────────────

	-- If line starts with "#!" and we're typing a non-space path-ish thing
	-- Example matches:
	--   "#!/usr/bin/ba"
	--   "#!/bin/ba"
	--   "#!/usr/bin/env"
	if before:match("^#!%S*$") then
		return true
	end

	-- Also treat "#!.../xxx" as path context even if more chars follow
	if before:match("^#!.*/[%w%._%-]*$") then
		return true
	end

	-- ─────────────────────────────────────────────
	-- General path patterns (work everywhere else too)
	-- ~/  ./  ../  foo/  /usr/...
	-- ─────────────────────────────────────────────

	if before:match("~/?$") then
		return true
	end

	if before:match("^%s*%./[%w%._%-]*$") then
		return true
	end

	if before:match("^%s*%.%./[%w%._%-]*$") then
		return true
	end

	if before:match("/[%w%._%-]*$") then
		return true
	end

	return false
end

local function trigger_path_completion()
	if vim.fn.pumvisible() == 1 then
		return
	end

	if is_path_context() then
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-x><C-f>", true, false, true), "n", false)
	end
end

vim.api.nvim_create_autocmd("TextChangedI", {
	callback = trigger_lsp_completion,
})

vim.api.nvim_create_autocmd("TextChangedI", {
	callback = trigger_path_completion,
})

-- Enter: confirm completion if menu is open, otherwise newline
vim.keymap.set("i", "<CR>", function()
	if vim.fn.pumvisible() == 1 and vim.fn.complete_info().selected ~= -1 then
		return "<C-y>"
	end
	return "<CR>"
end, { expr = true, silent = true })

-- Tab: next item when menu is open, otherwise real Tab
vim.keymap.set("i", "<Tab>", function()
	-- If popup menu is visible, select next item
	if vim.fn.pumvisible() == 1 then
		return "<C-n>"
	end

	-- Fallback: insert a real Tab
	return "<Tab>"
end, { expr = true, silent = true })

-- Shift-Tab: previous item when menu is open, otherwise real Shift-Tab
vim.keymap.set("i", "<S-Tab>", function()
	if vim.fn.pumvisible() == 1 then
		return "<C-p>"
	end
	return "<S-Tab>"
end, { expr = true, silent = true })

-- ===============================================================================
-- formating
-- ===============================================================================
local function format_buffer()
	local ft = vim.bo.filetype

	-- Python: use Ruff CLI formatter
	if ft == "python" then
		if vim.fn.executable("ruff") == 1 then
			-- format whole file with: ruff format -
			-- the "-" tells ruff to read from stdin
			vim.cmd([[silent %!ruff format -]])
		else
			vim.notify("ruff not installed (need `ruff` in PATH)", vim.log.levels.WARN)
		end
		return
	end

	-- Bash/sh: use shfmt CLI
	if ft == "sh" or ft == "bash" then
		if vim.fn.executable("shfmt") == 1 then
			vim.cmd([[silent %!shfmt]])
		else
			vim.notify("shfmt not installed (need `shfmt` in PATH)", vim.log.levels.WARN)
		end
		return
	end

	-- Fallback: LSP formatter if any
	vim.lsp.buf.format({ async = false })
end

vim.api.nvim_create_autocmd("BufWritePre", {
	callback = function()
		format_buffer()
	end,
})

vim.keymap.set({ "n", "v" }, "<leader>cf", format_buffer, { desc = "Code Format" })
