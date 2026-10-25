return {
  "linux-cultist/venv-selector.nvim",

  ft = { "python", "ipynb", "jupyter", "json" },

  dependencies = {
    "neovim/nvim-lspconfig",
    "nvim-telescope/telescope.nvim",
  },

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
    local tools = require("utils.python_tools")

    venv.setup(opts)

    local uv = vim.uv or vim.loop

    local session_cache = {}

    local function log(msg, level)
      vim.notify(msg, level or vim.log.levels.INFO, {
        title = "venv-selector",
      })
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
      local name = leaf

      if leaf == ".venv" or leaf == "venv" or leaf == "env" then
        name = vim.fn.fnamemodify(path, ":h:t")
      end

      -- Make Jupyter safe (lowercase, only alphanumeric/hyphens/underscores)
      name = string.lower(name)
      name = string.gsub(name, "[^a-z0-9%-_]", "_")

      return name
    end

    ------------------------------------------------------------
    -- Async kernel setup
    ------------------------------------------------------------
    local function ensure_kernel_async(py, name)
      -- Pass tools.local_tooling here!
      tools.ensure(py, tools.local_tooling, log, function(ok)
        if not ok then
          return
        end

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
        }, { text = true }, function(obj)
          vim.schedule(function()
            if obj.code == 0 then
              log("Kernel ready: " .. name)
              -- Notify user they can now use Molten
              vim.notify(
                "Jupyter Kernel '" .. name .. "' created! You can now run :MoltenInit",
                vim.log.levels.INFO
              )
            else
              log("Failed creating kernel: " .. name, vim.log.levels.ERROR)
            end
          end)
        end)
      end)
    end

    ------------------------------------------------------------
    -- Helper to read kernel.json and verify the python path
    ------------------------------------------------------------
    local function verify_kernel_path(kernel_json_path, current_py_path)
      local f = io.open(kernel_json_path, "r")
      if not f then
        return false
      end
      local content = f:read("*a")
      f:close()
      -- Returns true if the exact current python path is inside the json
      return content:find(current_py_path, 1, true) ~= nil
    end

    ------------------------------------------------------------
    -- Activate venv (Updated Logic)
    ------------------------------------------------------------
    local function activate(path)
      local py = python_from_venv(path)
      vim.env.VIRTUAL_ENV = path
      vim.env.PATH = path .. "/bin:" .. vim.env.PATH

      pcall(function()
        vim.cmd("LspRestart basedpyright")
      end)
      pcall(function()
        vim.cmd("LspRestart ruff")
      end)
      log("Activated: " .. path)

      if not session_cache[path] then
        session_cache[path] = true
        local name = kernel_name(path)
        local kernel_json = vim.fn.expand("~/.local/share/jupyter/kernels/")
          .. name
          .. "/kernel.json"

        local requires_kernel_build = true
        if exists(kernel_json) then
          if verify_kernel_path(kernel_json, py) then
            requires_kernel_build = false
          end
        end

        if requires_kernel_build then
          log("Building/Updating Jupyter kernel...", vim.log.levels.WARN)
          ensure_kernel_async(py, name)
        else
          tools.ensure(py, tools.local_tooling, log)
        end
      end
    end

    ------------------------------------------------------------
    -- Auto detect
    ------------------------------------------------------------
    local function auto_detect()
      local cwd = vim.fn.getcwd()

      local candidates = {
        join(cwd, ".venv"),
        join(cwd, "venv"),
        join(cwd, "env"),
      }

      for _, dir in ipairs(candidates) do
        if exists(python_from_venv(dir)) then
          if vim.env.VIRTUAL_ENV ~= dir then
            activate(dir)
          end

          return
        end
      end
    end

    ------------------------------------------------------------
    -- Keymaps
    ------------------------------------------------------------
    vim.keymap.set("n", "<leader>vs", "<cmd>VenvSelect<CR>", { desc = "Select Python venv" })

    vim.keymap.set("n", "<leader>vr", auto_detect, { desc = "Reload Python venv" })

    ------------------------------------------------------------
    -- Autocmds
    ------------------------------------------------------------
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "python", "ipynb" },

      callback = auto_detect,
    })

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
