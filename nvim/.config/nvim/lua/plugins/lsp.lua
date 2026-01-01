return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    { "antosha417/nvim-lsp-file-operations", config = true },
  },
  config = function()
    ------------------------------------------------------------------
    -- LSP keymaps (native, no Telescope, no workspace)
    ------------------------------------------------------------------
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
      callback = function(ev)
        local buf = ev.buf
        local opts = { buffer = buf, silent = true }

        local function map(mode, lhs, rhs, desc)
          opts.desc = desc
          vim.keymap.set(mode, lhs, rhs, opts)
        end

        -- Navigation / info (standard)
        map("n", "gd", vim.lsp.buf.definition, "Go to definition")
        map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
        map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
        map("n", "gr", vim.lsp.buf.references, "Go to references")
        map("n", "K", vim.lsp.buf.hover, "Hover documentation")

        -- Actions
        map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
        map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
        map("n", "<leader>D", vim.lsp.buf.type_definition, "Type definition")

        -- Formatting (common convention)
        map({ "n", "v" }, "<leader>f", function()
          vim.lsp.buf.format({ async = true })
        end, "Format buffer")

        -- Diagnostics
        map("n", "gl", vim.diagnostic.open_float, "Line diagnostics")
        map("n", "[d", function()
          vim.diagnostic.jump({ count = -1, float = true })
        end, "Previous diagnostic")
        map("n", "]d", function()
          vim.diagnostic.jump({ count = 1, float = true })
        end, "Next diagnostic")

        -- Diagnostic lists (copy-friendly)
        map("n", "gld", vim.diagnostic.setloclist, "Diagnostics (buffer)")
        map("n", "gLd", vim.diagnostic.setqflist, "Diagnostics (workspace)")

        -- Signature help (insert mode)
        map("i", "<C-k>", vim.lsp.buf.signature_help, "Signature help")
      end,
    })

    ------------------------------------------------------------------
    -- Diagnostics UI
    ------------------------------------------------------------------
    vim.diagnostic.config({
      virtual_text = true,
      underline = true,
      update_in_insert = false,
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = " ",
          [vim.diagnostic.severity.WARN] = " ",
          [vim.diagnostic.severity.HINT] = "󰠠 ",
          [vim.diagnostic.severity.INFO] = " ",
        },
      },
    })

    ------------------------------------------------------------------
    -- Capabilities (ONLY for cmp)
    ------------------------------------------------------------------
    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    vim.lsp.config("*", { capabilities = capabilities })

    ------------------------------------------------------------------
    -- Servers
    ------------------------------------------------------------------

    -- lua_ls
    vim.lsp.config("lua_ls", {
      settings = {
        Lua = {
          diagnostics = { globals = { "vim" } },
          completion = { callSnippet = "Replace" },
          workspace = {
            library = vim.api.nvim_get_runtime_file("", true),
            checkThirdParty = false,
          },
          telemetry = { enable = false },
        },
      },
    })
    vim.lsp.enable("lua_ls")

    -- eslint
    vim.lsp.config("eslint", {
      cmd = { "vscode-eslint-language-server", "--stdio" },
      filetypes = {
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "vue",
        "svelte",
      },
      settings = {
        eslint = {
          workingDirectory = { mode = "auto" },
        },
      },
      single_file_support = true,
    })
    vim.lsp.enable("eslint")

    -- ts_ls
    vim.lsp.config("ts_ls", {
      filetypes = {
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
      },
      single_file_support = true,
    })
    vim.lsp.enable("ts_ls")

    -- gopls
    vim.lsp.config("gopls", {
      settings = {
        gopls = {
          analyses = { unusedparams = true },
          staticcheck = true,
          gofumpt = true,
        },
      },
    })
    vim.lsp.enable("gopls")

    -- pyright
    vim.lsp.config("pyright", {
      settings = {
        python = {
          analysis = {
            typeCheckingMode = "standard",
            diagnosticMode = "workspace",
            autoSearchPaths = true,
            useLibraryCodeForTypes = true,
            reportUnusedImports = true,
            reportUnusedVariable = true,
            reportOptionalMemberAccess = true,
            reportOptionalSubscript = true,
            reportOptionalIterable = true,
            reportMissingTypeStubs = false,
            reportUnknownMemberType = true,
            reportUnknownVariableType = true,
          },
        },
      },
    })
    vim.lsp.enable("pyright")

    -- ruff
    vim.lsp.config("ruff", {
      settings = {
        lint = {
          select = {
            "E", -- pycodestyle
            "F", -- pyflakes
            "B", -- bugbear
            "SIM", -- simplify
            "UP", -- pyupgrade
            "I", -- imports
          },
        },
      },
    })
    vim.lsp.enable("ruff")

    -- clangd
    vim.lsp.config("clangd", {
      cmd = {
        "clangd",
        "--background-index",
        "--clang-tidy",
        "--completion-style=detailed",
        "--cross-file-rename",
        "--header-insertion=never",
      },
    })
    vim.lsp.enable("clangd")

    -- bashls
    vim.lsp.enable("bashls")
  end,
}
