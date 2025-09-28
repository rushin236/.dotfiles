return {
  "mason-org/mason.nvim",
  lazy = false,
  dependencies = {
    "mason-org/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    "hrsh7th/cmp-nvim-lsp",
    "neovim/nvim-lspconfig",
    -- "saghen/blink.cmp",
  },
  config = function()
    -- import mason and mason_lspconfig
    local mason = require("mason")
    local mason_lspconfig = require("mason-lspconfig")
    local mason_tool_installer = require("mason-tool-installer")

    -- NOTE: Moved these local imports below back to lspconfig.lua due to mason depracated handlers

    -- local lspconfig = require("lspconfig")
    -- local cmp_nvim_lsp = require("cmp_nvim_lsp")             -- import cmp-nvim-lsp plugin
    -- local capabilities = cmp_nvim_lsp.default_capabilities() -- used to enable autocompletion (assign to every lsp server config)

    -- enable mason and configure icons
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
      automatic_enable = false,
      -- servers for mason to install
      ensure_installed = {
        "lua_ls", -- lua-language-server
        "ts_ls", -- ts and js language server
        "html", -- html language server
        "cssls", -- css language server
        "gopls", -- go language server, linter, formatter
        "eslint", -- ts and js linter
        "marksman", -- markdown language server
        "pyright", -- python-language-server
        "ruff", -- python-language-server, linter, formatter
        "clangd", -- c and cpp language server
      },
    })

    mason_tool_installer.setup({
      ensure_installed = {
        "prettier", -- prettier formatter
        "stylua", -- lua formatter
        "isort", -- python formatter
        "black", -- python formatter
        "eslint_d", -- JS and TS linting
        "cpplint", -- c, cpp linter
        "clang-format", -- c, cpp formatter
        "codelldb", -- c, cpp debugger
        "markdown-toc", -- markdown formatter
      },

      -- NOTE: mason BREAKING Change! Removed setup_handlers
      -- moved lsp configuration settings back into lspconfig.lua file
    })
  end,
}
