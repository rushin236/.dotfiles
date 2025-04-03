return {
  -- add any tools you want to have installed below
  {
    "williamboman/mason.nvim",
    event = { "CmdlineEnter" },
    config = function()
      local mason = require("mason")
      mason.setup({
        ui = {
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
          },
        },
      })
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    event = { "CmdlineEnter" },
    config = function()
      local mason_lspconfig = require("mason-lspconfig")
      mason_lspconfig.setup({
        automatic_installation = true,
        ensure_installed = {
          "lua_ls", -- Lua
          "pyright", -- Python
          "cssls", -- CSS
          "html", -- HTML
          "ts_ls", -- JavaScript and TypeScript
          "ruff", -- Ruff
          "bashls", -- bash-language-server
          "clangd", -- c programming
        },
      })
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    event = { "CmdlineEnter" },
    config = function()
      local mason_tool_installer = require("mason-tool-installer")
      mason_tool_installer.setup({
        ensure_installed = {
          "prettier", -- formatter for multiple languages
          "prettierd", -- formatter for multiple languages
          "stylua", -- Lua formatter
          "isort", -- Python import sorter
          "black", -- Python formatter
          "trivy", -- JavaScript linter
          "ruff", -- Python linter
          -- "pylint", -- Python linter (commented out)
          "beautysh", -- bash formatting
          "shellcheck",
        },
      })
    end,
  },
}
