return {
  {
    "mason-org/mason.nvim",
    version = "^1.0.0",
    opts = {
      ensure_installed = {
        "lua-language-server", -- Lua
        "pyright", -- Python
        "css-lsp", -- CSS
        "html-lsp", -- HTML
        "typescript-language-server", -- JavaScript and TypeScript
        "bash-language-server", -- bash-language-server
        "clangd", -- c programming
        "clang-format", -- c formatter
        "prettier", -- formatter for multiple languages
        "stylua", -- Lua formatter
        "isort", -- Python import sorter
        "black", -- Python formatter
        "debugpy", -- Python debug
        "trivy", -- JavaScript linter
        "ruff", -- Python linter
        "beautysh", -- bash formatting
        "shellcheck",
        "markdownlint-cli2", -- markdown linter
        "marksman", -- markdown lsp
      },
    },
  },
  { "mason-org/mason-lspconfig.nvim", version = "^1.0.0" },
}
