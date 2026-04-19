return {
  "linux-cultist/venv-selector.nvim",
  ft = { "python", "ipynb", "jupyter", "json" },
  dependencies = { "neovim/nvim-lspconfig", "nvim-telescope/telescope.nvim" },
  opts = {
    name = { ".venv", "venv", "env" },
    auto_refresh = true,
    search_workspace = true,
    search_venv_managers = true,
    stay_on_this_version = true,
    parents = 3,
  },
  config = function(_, opts)
    local venv = require("venv-selector")
    venv.setup(opts)
    local uv = vim.uv or vim.loop

    -- Cache to prevent checking the same venv multiple times per session
    local session_cache = {}

    local function log(msg, level)
      vim.notify(msg, level or vim.log.levels.INFO, { title = "venv-selector" })
    end

    local function exists(path)
      return uv.fs_stat(path) ~= nil
    end
    local function join(...)
      return table.concat({ ... }, "/")
    end
    local function python_from_venv(path)
      return join(path, "bin", "python")
    end

    local function kernel_name(path)
      local leaf = vim.fn.fnamemodify(path, ":t")
      if leaf == ".venv" or leaf == "venv" or leaf == "env" then
        return vim.fn.fnamemodify(path, ":h:t")
      end
      return leaf
    end

    ------------------------------------------------------------
    -- Async Background Tooling (The Snappy Secret)
    ------------------------------------------------------------
    local function ensure_kernel_async(py, name)
      -- Use Neovim 0.10+ async system command. UI never freezes!
      vim.system({
        py,
        "-m",
        "pip",
        "install",
        "-U",
        "ipykernel",
        "debugpy",
        "ruff", -- ONLY install what the project needs
      }, { text = true }, function(obj)
        if obj.code == 0 then
          -- Once ipykernel is installed, register it with Jupyter
          vim.system({
            py,
            "-m",
            "ipykernel",
            "install",
            "--user",
            "--name",
            name,
            "--display-name",
            "Python (" .. name .. ")",
          }, { text = true }, function(k_obj)
            if k_obj.code == 0 then
              vim.schedule(function()
                log("Kernel ready: " .. name)
              end)
            end
          end)
        else
          vim.schedule(function()
            log("Failed to install ipykernel in " .. name, vim.log.levels.ERROR)
          end)
        end
      end)
    end

    ------------------------------------------------------------
    -- Activate venv
    ------------------------------------------------------------
    local function activate(path)
      local py = python_from_venv(path)
      if not exists(py) then
        return
      end

      -- 1. Instantly update Neovim's environment
      vim.env.VIRTUAL_ENV = path
      vim.env.PATH = path .. "/bin:" .. vim.env.PATH

      -- 2. Safely restart LSPs
      pcall(function()
        vim.cmd("LspRestart pyright")
      end)
      pcall(function()
        vim.cmd("LspRestart ruff")
      end)

      log("Activated: " .. path)

      -- 3. If we haven't processed this venv yet today, check it in the background
      if not session_cache[path] then
        session_cache[path] = true
        local name = kernel_name(path)

        -- Check if kernel JSON exists synchronously (takes 1 millisecond)
        local json_path = vim.fn.expand("~/.local/share/jupyter/kernels/") .. name .. "/kernel.json"
        if not exists(json_path) then
          log("Building Jupyter kernel in background...", vim.log.levels.WARN)
          ensure_kernel_async(py, name)
        end
      end
    end

    ------------------------------------------------------------
    -- Auto detect local venv
    ------------------------------------------------------------
    local function auto_detect()
      local cwd = vim.fn.getcwd()
      local candidates = { join(cwd, ".venv"), join(cwd, "venv"), join(cwd, "env") }

      for _, dir in ipairs(candidates) do
        if exists(python_from_venv(dir)) then
          -- Only trigger activate if it's different from the current one
          if vim.env.VIRTUAL_ENV ~= dir then
            activate(dir)
          end
          return
        end
      end
    end

    ------------------------------------------------------------
    -- Keymaps & Autocmds
    ------------------------------------------------------------
    vim.keymap.set("n", "<leader>vs", "<cmd>VenvSelect<CR>", { desc = "Select Python venv" })
    vim.keymap.set("n", "<leader>vr", auto_detect, { desc = "Reload Python venv" })

    -- Trigger on file open
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "python", "ipynb" },
      callback = auto_detect,
    })

    -- Listen to venv-selector's internal event when you manually pick a venv from Telescope
    vim.api.nvim_create_autocmd("User", {
      pattern = "VenvSelect",
      callback = function()
        local path = vim.env.VIRTUAL_ENV
        if path and path ~= "" then
          activate(path)
        end
      end,
    })
  end,
}
