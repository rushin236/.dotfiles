---@brief
---
--- https://clangd.llvm.org/installation.html
---
--- - **NOTE:** Clang >= 11 is recommended! See [#23](https://github.com/neovim/nvim-lspconfig/issues/23).
--- - If `compile_commands.json` lives in a build directory, you should
---   symlink it to the root of your source tree.
---   ```
---   ln -s /path/to/myproject/build/compile_commands.json /path/to/myproject/
---   ```
--- - clangd relies on a [JSON compilation database](https://clang.llvm.org/docs/JSONCompilationDatabase.html)
---   specified as compile_commands.json, see https://clangd.llvm.org/installation#compile_commandsjson

-- https://clangd.llvm.org/extensions.html#switch-between-sourceheader
local function switch_source_header(bufnr, client)
  local method_name = "textDocument/switchSourceHeader"
  if not client or not client:supports_method(method_name) then
    return vim.notify(
      ("method %s is not supported by any servers active on the current buffer"):format(method_name)
    )
  end
  local params = vim.lsp.util.make_text_document_params(bufnr)
  client:request(method_name, params, function(err, result)
    if err then
      error(tostring(err))
    end
    if not result then
      vim.notify("corresponding file cannot be determined")
      return
    end
    vim.cmd.edit(vim.uri_to_fname(result))
  end, bufnr)
end

local function symbol_info(bufnr, client)
  local method_name = "textDocument/symbolInfo"
  if not client or not client:supports_method(method_name) then
    return vim.notify("Clangd client not found", vim.log.levels.ERROR)
  end
  local win = vim.api.nvim_get_current_win()
  local params = vim.lsp.util.make_position_params(win, client.offset_encoding)
  client:request(method_name, params, function(err, res)
    if err or not res or #res == 0 then
      return
    end
    local container = string.format("container: %s", res[1].containerName or "")
    local name = string.format("name: %s", res[1].name or "")
    vim.lsp.util.open_floating_preview({ name, container }, "", {
      height = 2,
      width = math.max(#name, #container),
      focusable = false,
      focus = false,
      title = "Symbol Info",
    })
  end, bufnr)
end

---@class ClangdInitializeResult: lsp.InitializeResult
---@field offsetEncoding? string

---@type vim.lsp.Config
return {
  name = "clangd",
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--completion-style=detailed",
    "--header-insertion=iwyu",
    "--offset-encoding=utf-16",
  },

  filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },

  root_markers = {
    ".clangd",
    ".clang-tidy",
    ".clang-format",
    "compile_commands.json",
    "compile_flags.txt",
    "configure.ac", -- AutoTools
    ".git",
  },

  capabilities = {
    textDocument = {
      completion = {
        editsNearCursor = true,
      },
      -- clangd supports signatureHelp out of the box, nothing special needed,
      -- your global <C-k> mapping will just work in C/C++ files.
    },
    offsetEncoding = { "utf-8", "utf-16" },
  },

  -- clangd-specific extras
  init_options = {
    clangdFileStatus = true,     -- show file status in LSP
    semanticHighlighting = true, -- (older clangd) semantic tokens
    inlayHints = {
      parameterNames = true,
      parameterTypes = true,
      variableTypes = true,
      templateParameters = true,
    },
  },

  ---@param client vim.lsp.Client
  ---@param init_result ClangdInitializeResult
  on_init = function(client, init_result)
    if init_result and init_result.offsetEncoding then
      client.offset_encoding = init_result.offsetEncoding
    end
  end,

  ---@param client vim.lsp.Client
  ---@param bufnr integer
  on_attach = function(client, bufnr)
    vim.api.nvim_buf_create_user_command(bufnr, "LspClangdSwitchSourceHeader", function()
      switch_source_header(bufnr, client)
    end, { desc = "Switch between source/header" })

    vim.api.nvim_buf_create_user_command(bufnr, "LspClangdShowSymbolInfo", function()
      symbol_info(bufnr, client)
    end, { desc = "Show symbol info" })
  end,
}
