local M = {}
local uv = vim.uv or vim.loop

-- 1. GLOBAL TOOLS (Installed ONCE in ~/.local/share/nvim-python)
M.host_tooling = {
  { pip = "pynvim", module = "pynvim" },
  { pip = "basedpyright", executable = "basedpyright-langserver" },
  { pip = "jupytext", executable = "jupytext" },
  { pip = "jupyter", executable = "jupyter" },
  { pip = "jupyter_client", module = "jupyter_client" },
  { pip = "jupyter_core", module = "jupyter_core" },
  { pip = "nbformat", module = "nbformat" },
  { pip = "pyzmq", module = "zmq" },
  { pip = "traitlets", module = "traitlets" },
  { pip = "tornado", module = "tornado" },
  { pip = "ruff", executable = "ruff" },
  { pip = "cairosvg", module = "cairosvg" },
  { pip = "pnglatex", executable = "pnglatex" },
  { pip = "pylatexenc", module = "pylatexenc" },
  { pip = "plotly", module = "plotly" },
  { pip = "kaleido", module = "kaleido" },
  { pip = "pyperclip", module = "pyperclip" },
  { pip = "pillow", module = "PIL" },
}

-- 2. LOCAL TOOLS (Installed in every project's .venv)
M.local_tooling = {
  { pip = "ipykernel", module = "ipykernel" },
  { pip = "debugpy", module = "debugpy" },
}

function M.exists(path)
  return uv.fs_stat(path) ~= nil
end

function M.join(...)
  return table.concat({ ... }, "/")
end

function M.check_module(py, mod, cb)
  vim.system({ py, "-c", "import " .. mod }, { text = true }, function(obj)
    vim.schedule(function()
      cb(obj.code == 0)
    end)
  end)
end

function M.check_executable(exe, cb)
  vim.schedule(function()
    cb(vim.fn.executable(exe) == 1)
  end)
end

-- Modified to accept which list to check (host or local)
function M.find_missing(py, tooling_list, cb)
  local missing = {}
  local pending = #tooling_list

  local function done()
    pending = pending - 1
    if pending == 0 then
      cb(missing)
    end
  end

  for _, tool in ipairs(tooling_list) do
    if tool.module then
      M.check_module(py, tool.module, function(ok)
        if not ok then
          table.insert(missing, tool.pip)
        end
        done()
      end)
    elseif tool.executable then
      M.check_executable(tool.executable, function(ok)
        if not ok then
          table.insert(missing, tool.pip)
        end
        done()
      end)
    else
      done()
    end
  end
end

function M.install_missing(py, packages, log, cb)
  if #packages == 0 then
    if cb then
      cb(true)
    end
    return
  end

  -- ADDED: A visible notification so you know it's working
  vim.notify("Installing " .. #packages .. " Python packages. Please wait...", vim.log.levels.WARN)
  log("Installing: " .. table.concat(packages, ", "))

  local cmd = vim.list_extend({ py, "-m", "pip", "install", "-U" }, packages)

  vim.system(cmd, { text = true }, function(obj)
    vim.schedule(function()
      if obj.code == 0 then
        vim.notify("Python tooling installed successfully!", vim.log.levels.INFO)
        log("Python tooling ready")
        if cb then
          cb(true)
        end
      else
        vim.notify("Failed to install Python tooling", vim.log.levels.ERROR)
        log("Failed installing Python tooling", vim.log.levels.ERROR)
        if cb then
          cb(false)
        end
      end
    end)
  end)
end

-- Modified to accept tooling_list
function M.ensure(py, tooling_list, log, cb)
  M.find_missing(py, tooling_list, function(missing)
    M.install_missing(py, missing, log, cb)
  end)
end

return M
