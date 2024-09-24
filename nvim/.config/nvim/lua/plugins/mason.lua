return {
  {
    "williamboman/mason.nvim",
    event = { "CmdlineEnter" },
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
    },
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
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      local mason_lspconfig = require("mason-lspconfig")
      mason_lspconfig.setup({
        ensure_installed = {
          "lua_ls", -- Lua
          "pyright", -- Python
          "cssls", -- CSS
          "html", -- HTML
          "ts_ls", -- JavaScript and TypeScript
          "ruff_lsp",
          "bashls", -- bash-language-server
        },
        automatic_installation = true,
      })
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    event = { "CmdlineEnter" },
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      local mason_tool_installer = require("mason-tool-installer")
      mason_tool_installer.setup({
        ensure_installed = {
          "prettier", -- formatter for multiple languages
          "stylua", -- Lua formatter
          "isort", -- Python import sorter
          "black", -- Python formatter
          "eslint_d", -- JavaScript linter
          "ruff", -- Python linter
          -- "pylint", -- Python linter (commented out)
          "shfmt", -- bash formatting
        },
      })
    end,
  },
}
