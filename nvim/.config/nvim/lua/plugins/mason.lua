return {
  "williamboman/mason.nvim",
  event = { "CmdlineEnter" },
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  config = function()
    local mason = require("mason")

    local mason_lspconfig = require("mason-lspconfig")

    local mason_tool_installer = require("mason-tool-installer")

    mason.setup({
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })

    mason_lspconfig.setup({
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
      automatic_installation = true,
    })

    mason_tool_installer.setup({
      ensure_installed = {
        "prettier", -- formatter for multiple languages
        "stylua", -- Lua formatter
        "isort", -- Python import sorter
        "black", -- Python formatter
        "eslint_d", -- JavaScript linter
        "ruff", -- Python linter
        -- "pylint", -- Python linter (commented out)
        "beautysh", -- bash formatting
        "shellcheck",
        "clang-format", -- c formatter
      },
    })
  end,
}
