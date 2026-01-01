---@brief
--- https://github.com/microsoft/pyright
--- `pyright`, a static type checker and language server for Python

local function set_python_path(command)
  local path = command.args
  local clients = vim.lsp.get_clients {
    bufnr = vim.api.nvim_get_current_buf(),
    name = "pyright",
  }

  for _, client in ipairs(clients) do
    if client.settings then
      client.settings.python =
          vim.tbl_deep_extend("force", client.settings.python --[[@as table]], { pythonPath = path })
    else
      client.config.settings = vim.tbl_deep_extend("force", client.config.settings or {},
        { python = { pythonPath = path } })
    end
    client:notify("workspace/didChangeConfiguration", { settings = nil })
  end
end

---@type vim.lsp.Config
return {
  name = "pyright",
  cmd = { "pyright-langserver", "--stdio" },
  filetypes = { "python" },

  root_markers = {
    "pyrightconfig.json",
    "pyproject.toml",
    "setup.py",
    "setup.cfg",
    "requirements.txt",
    "Pipfile",
    ".git",
  },

  settings = {
    python = {
      -- You can also set pythonPath here if you want a default
      -- pythonPath = "/usr/bin/python",

      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        autoImportCompletions = true,
        diagnosticMode = "openFilesOnly", -- or "workspace"
        typeCheckingMode = "basic",       -- "off" | "basic" | "strict"

        inlayHints = {
          variableTypes = true,
          functionReturnTypes = true,
          callArgumentNames = "all", -- "none" | "partial" | "all"
          pytestParameters = true,
          genericTypes = true,
        },
      },
    },
  },

  on_attach = function(client, bufnr)
    -- Organize imports
    vim.api.nvim_buf_create_user_command(bufnr, "LspPyrightOrganizeImports", function()
      local params = {
        command = "pyright.organizeimports",
        arguments = { vim.uri_from_bufnr(bufnr) },
      }

      -- private command → must use client.request directly
      ---@diagnostic disable-next-line: param-type-mismatch
      client.request("workspace/executeCommand", params, nil, bufnr)
    end, {
      desc = "Organize Imports",
    })

    -- Runtime pythonPath override
    vim.api.nvim_buf_create_user_command(bufnr, "LspPyrightSetPythonPath", set_python_path, {
      desc = "Reconfigure pyright with the provided python path",
      nargs = 1,
      complete = "file",
    })
  end,
}
