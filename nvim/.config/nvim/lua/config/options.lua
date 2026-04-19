------------------------------------------------------------------
-- Python runtime for Neovim / Molten / Jupyter
-- Put near top of options.lua
------------------------------------------------------------------
do
  local uv = vim.uv or vim.loop
  local host_dir = vim.fn.expand("~/.local/share/nvim-python")
  local host_python = host_dir .. "/bin/python"
  local runtime_dir = vim.fn.expand("~/.local/share/jupyter/runtime")
  local kernel_dir = vim.fn.expand("~/.local/share/jupyter/kernels/nvim")
  local kernel_json = kernel_dir .. "/kernel.json"

  local function log(msg, hl)
    vim.api.nvim_echo({ { "[python] " .. msg, hl or "None" } }, true, {})
  end

  local function exists(path)
    return uv.fs_stat(path) ~= nil
  end

  local function run(cmd)
    local out = vim.fn.system(cmd)
    local ok = vim.v.shell_error == 0
    if not ok then
      log("Failed: " .. table.concat(cmd, " "), "ErrorMsg")
    end
    return ok, out
  end

  local function ensure_host_packages()
    run({ host_python, "-m", "pip", "install", "-U", "pip" })
    -- THIS is where all the heavy Molten/Jupyter tools go
    run({
      host_python,
      "-m",
      "pip",
      "install",
      "-U",
      "pynvim",
      "jupyter",
      "ipykernel",
      "jupyter_client",
      "jupyter_core",
      "nbformat",
      "pyzmq",
      "traitlets",
      "tornado",
      "debugpy",
      "ruff",
      "cairosvg",
      "pnglatex",
      "plotly",
      "kaleido",
      "pyperclip",
      "pillow",
    })
  end

  local function recreate_kernel()
    vim.fn.delete(kernel_dir, "rf")
    run({
      host_python,
      "-m",
      "ipykernel",
      "install",
      "--user",
      "--name",
      "nvim",
      "--display-name",
      "Python (nvim_host)",
    })
  end

  if vim.fn.executable("python3") == 0 then
    return
  end
  vim.fn.mkdir(runtime_dir, "p")

  -- 1. THE SLOW PATH: Block startup ONLY if the global Neovim host is missing
  if not exists(host_python) then
    log("Creating Neovim Python host... (Blocking once)", "MoreMsg")
    run({ "python3", "-m", "venv", host_dir })
    ensure_host_packages()
    recreate_kernel()
    log("Neovim Python host created!", "Question")
  elseif not exists(kernel_json) then
    recreate_kernel()
  end

  -- 2. THE FAST PATH: Set the global provider for Molten and plugins
  vim.g.python3_host_prog = host_python

  -- We intentionally DO NOT set vim.env.VIRTUAL_ENV here globally anymore.
  -- We leave that job exclusively to venv-selector so your terminal
  -- defaults to your project, not Neovim's internal host.
end

-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- line numbers
vim.opt.nu = true
vim.opt.relativenumber = true

-- indentation
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false

-- backup and undo
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

-- search
vim.opt.inccommand = "split"

-- UI
vim.opt.background = "dark"
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.winborder = "rounded"

-- folding (for nvim-ufo)
vim.o.foldenable = true
vim.o.foldmethod = "manual"
vim.o.foldlevel = 99
vim.o.foldcolumn = "0"

-- window splits
vim.opt.splitright = true
vim.opt.splitbelow = true

-- misc
-- vim.opt.colorcolumn = "80"
vim.opt.cursorline = true
vim.opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus"
vim.opt.mouse = "a"

-- save
vim.g.autoformat = true

vim.opt.guicursor = {
  "n-v-c:block",
  "i:block-blinkon200-blinkoff200-blinkwait100",
  "r:block",
  "o:block",
}

vim.opt.wildmenu = true
vim.opt.wildmode = "longest:full,full"
vim.opt.wildoptions = "pum"
vim.opt.pumheight = 10
vim.opt.pumblend = 10

vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
