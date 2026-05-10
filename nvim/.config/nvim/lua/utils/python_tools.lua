local M = {}

local uv = vim.uv or vim.loop

M.tooling = {
  { pip = "pynvim", module = "pynvim" },
  { pip = "jupyter", executable = "jupyter" },
  { pip = "ipykernel", module = "ipykernel" },
  { pip = "jupyter_client", module = "jupyter_client" },
  { pip = "jupyter_core", module = "jupyter_core" },
  { pip = "nbformat", module = "nbformat" },
  { pip = "pyzmq", module = "zmq" },
  { pip = "traitlets", module = "traitlets" },
  { pip = "tornado", module = "tornado" },
  { pip = "debugpy", module = "debugpy" },
  { pip = "ruff", executable = "ruff" },
  { pip = "cairosvg", module = "cairosvg" },
  { pip = "pnglatex", executable = "pnglatex" },
  { pip = "pylatexenc", module = "pylatexenc" },
  { pip = "plotly", module = "plotly" },
  { pip = "kaleido", module = "kaleido" },
  { pip = "pyperclip", module = "pyperclip" },
  { pip = "pillow", module = "PIL" },
}

function M.exists(path)
  return uv.fs_stat(path) ~= nil
end

function M.join(...)
  return table.concat({ ... }, "/")
end

function M.check_module(py, mod, cb)
  vim.system({
    py,
    "-c",
    "import " .. mod,
  }, { text = true }, function(obj)
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

function M.find_missing(py, cb)
  local missing = {}
  local pending = #M.tooling

  local function done()
    pending = pending - 1
    if pending == 0 then
      cb(missing)
    end
  end

  for _, tool in ipairs(M.tooling) do
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

  log("Installing: " .. table.concat(packages, ", "))

  local cmd = vim.list_extend({
    py,
    "-m",
    "pip",
    "install",
    "-U",
  }, packages)

  vim.system(cmd, { text = true }, function(obj)
    vim.schedule(function()
      if obj.code == 0 then
        log("Python tooling ready")
        if cb then
          cb(true)
        end
      else
        log("Failed installing Python tooling", vim.log.levels.ERROR)
        if cb then
          cb(false)
        end
      end
    end)
  end)
end

function M.ensure(py, log, cb)
  M.find_missing(py, function(missing)
    M.install_missing(py, missing, log, cb)
  end)
end

return M
