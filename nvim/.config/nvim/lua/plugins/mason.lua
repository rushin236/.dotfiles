return {
  {
    "williamboman/mason.nvim",
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
        "trivy", -- JavaScript linter
        "ruff", -- Python linter
        "beautysh", -- bash formatting
        "shellcheck",
      },
    },
  },
}
