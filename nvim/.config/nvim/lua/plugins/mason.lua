return {
  "mason-org/mason.nvim",
  lazy = false,

  dependencies = {
    "mason-org/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    "neovim/nvim-lspconfig",
    "saghen/blink.cmp",
  },

  config = function()
    local mason = require("mason")
    local mason_lspconfig = require("mason-lspconfig")
    local mason_tool_installer = require("mason-tool-installer")

    mason.setup({
      ui = {
        border = "rounded",
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })

    ------------------------------------------------------------------
    -- LSP SERVERS
    ------------------------------------------------------------------
    mason_lspconfig.setup({
      automatic_enable = false,

      ensure_installed = {
        "lua_ls",

        "pyright",
        "ruff",

        "bashls",

        "clangd",

        "gopls",

        "rust_analyzer",

        "marksman",

        "yamlls",
        "taplo",

        "html",
        "tailwindcss",
      },
    })

    ------------------------------------------------------------------
    -- TOOLS
    ------------------------------------------------------------------
    mason_tool_installer.setup({
      ensure_installed = {
        --------------------------------------------------------------
        -- Formatters
        --------------------------------------------------------------
        "stylua",
        "ruff",
        "shfmt",
        "clang-format",
        "gofumpt",
        "golines",
        "markdownlint-cli2",
        "markdown-toc",
        "prettier",

        --------------------------------------------------------------
        -- Linters
        --------------------------------------------------------------
        "shellcheck",
        "cpplint",
        "golangci-lint",

        --------------------------------------------------------------
        -- Debuggers
        --------------------------------------------------------------
        "debugpy",
        "codelldb",
        "delve",
      },

      run_on_start = true,
      auto_update = false,
      start_delay = 3000,
      debounce_hours = 12,
    })
  end,
}
