------------------------------------------------------------------
-- Python runtime for Neovim / Molten / Jupyter
------------------------------------------------------------------
do
  -- local uv = vim.uv or vim.loop
  local tools = require("utils.python_tools")

  local host_dir = vim.fn.expand("~/.local/share/nvim-python")
  local host_python = host_dir .. "/bin/python"

  local runtime_dir = vim.fn.expand("~/.local/share/jupyter/runtime")

  local kernel_dir = vim.fn.expand("~/.local/share/jupyter/kernels/nvim")
  local kernel_json = kernel_dir .. "/kernel.json"

  local function log(msg, hl)
    vim.api.nvim_echo({
      { "[python] " .. msg, hl or "None" },
    }, true, {})
  end

  local function recreate_kernel()
    vim.system({
      host_python,
      "-m",
      "ipykernel",
      "install",
      "--user",
      "--name",
      "nvim",
      "--display-name",
      "Python (nvim_host)",
    }, { text = true }, function(obj)
      vim.schedule(function()
        if obj.code == 0 then
          log("Jupyter kernel ready", "Question")
        else
          log("Failed to create Jupyter kernel", "ErrorMsg")
        end
      end)
    end)
  end

  if vim.fn.executable("python3") == 0 then
    return
  end

  vim.fn.mkdir(runtime_dir, "p")

  ------------------------------------------------------------
  -- Create host venv once
  ------------------------------------------------------------
  if not tools.exists(host_python) then
    log("Creating Neovim Python host...", "MoreMsg")

    vim.system({
      "python3",
      "-m",
      "venv",
      host_dir,
    }, { text = true }, function(obj)
      vim.schedule(function()
        if obj.code ~= 0 then
          log("Failed creating Python host", "ErrorMsg")
          return
        end

        log("Installing host tooling...", "MoreMsg")

        tools.ensure(host_python, function(msg)
          log(msg, "None")
        end, function()
          recreate_kernel()
        end)
      end)
    end)
  else
    ------------------------------------------------------------
    -- Background tooling verification
    ------------------------------------------------------------
    tools.ensure(host_python, function(msg)
      log(msg, "None")
    end)

    ------------------------------------------------------------
    -- Recreate kernel if missing
    ------------------------------------------------------------
    if not tools.exists(kernel_json) then
      recreate_kernel()
    end
  end

  ------------------------------------------------------------
  -- Neovim Python provider
  ------------------------------------------------------------
  vim.g.python3_host_prog = host_python

  local host_bin = host_dir .. "/bin"

  if not vim.env.PATH:find(host_bin, 1, true) then
    vim.env.PATH = host_bin .. ":" .. vim.env.PATH
  end
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

vim.opt.updatetime = 200
vim.opt.timeoutlen = 300
vim.opt.completeopt = "menu,menuone,noselect"
vim.opt.shortmess:append("c")

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
