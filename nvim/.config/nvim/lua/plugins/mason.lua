return {
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
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "hrsh7th/nvim-cmp", -- Completion plugin
      "hrsh7th/cmp-nvim-lsp", -- LSP completion source for nvim-cmp
      { "antosha417/nvim-lsp-file-operations", config = true }, -- LSP-based file operations
      { "folke/neodev.nvim", opts = {} }, -- Neovim API support for Lua
    },
    config = function()
      -- Import required plugins
      local lspconfig = require("lspconfig")
      local mason_lspconfig = require("mason-lspconfig")
      local cmp_nvim_lsp = require("cmp_nvim_lsp")
      local keymap = vim.keymap -- for keybinding convenience

      -- Key mappings for LSP functionality
      local function on_attach(_, bufnr)
        local opts = { buffer = bufnr, silent = true }

        -- Helper function to merge opts
        local function set_keymap(mode, key, result, desc)
          vim.keymap.set(mode, key, result, vim.tbl_extend("force", opts, { desc = desc }))
        end

        -- Keymaps for LSP actions
        set_keymap("n", "gR", "<cmd>Telescope lsp_references<CR>", "Show LSP references")
        set_keymap("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
        set_keymap("n", "gd", "<cmd>Telescope lsp_definitions<CR>", "Show LSP definitions")
        set_keymap("n", "gi", "<cmd>Telescope lsp_implementations<CR>", "Show LSP implementations")
        set_keymap("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", "Show LSP type definitions")
        set_keymap({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "See available code actions")
        set_keymap("n", "<leader>rn", vim.lsp.buf.rename, "Smart rename")
        set_keymap("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", "Show buffer diagnostics")
        set_keymap("n", "<leader>d", vim.diagnostic.open_float, "Show line diagnostics")
        set_keymap("n", "[d", vim.diagnostic.goto_prev, "Go to previous diagnostic")
        set_keymap("n", "]d", vim.diagnostic.goto_next, "Go to next diagnostic")
        set_keymap("n", "K", vim.lsp.buf.hover, "Show documentation")
        set_keymap("n", "<leader>rs", ":LspRestart<CR>", "Restart LSP")
      end

      -- Setup diagnostic symbols
      local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
      end

      -- Set up capabilities for autocompletion
      local capabilities = cmp_nvim_lsp.default_capabilities()

      -- Configure installed LSP servers
      mason_lspconfig.setup_handlers({
        -- Default setup for all installed servers
        function(server_name)
          lspconfig[server_name].setup({
            capabilities = capabilities,
            on_attach = on_attach, -- Attach keybindings and settings
          })
        end,

        -- Custom settings for Lua LSP (lua_ls)
        ["lua_ls"] = function()
          lspconfig.lua_ls.setup({
            capabilities = capabilities,
            on_attach = on_attach,
            settings = {
              Lua = {
                diagnostics = { globals = { "vim" } }, -- Recognize Neovim's `vim` global
                completion = { callSnippet = "Replace" },
              },
            },
          })
        end,
      })
    end,
  },
}
