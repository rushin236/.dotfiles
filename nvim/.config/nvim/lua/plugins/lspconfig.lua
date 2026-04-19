return {
  "neovim/nvim-lspconfig",

  event = { "BufReadPre", "BufNewFile" },

  dependencies = {
    { "antosha417/nvim-lsp-file-operations", config = true },
    "saghen/blink.cmp",
  },

  config = function()
    ------------------------------------------------------------------
    -- Capabilities
    ------------------------------------------------------------------
    local capabilities = require("blink.cmp").get_lsp_capabilities()
    vim.lsp.config("*", { capabilities = capabilities })

    ------------------------------------------------------------------
    -- Diagnostics UI
    ------------------------------------------------------------------
    vim.diagnostic.config({
      virtual_text = true,
      underline = true,
      update_in_insert = false,
      severity_sort = true,
      float = {
        border = "rounded",
        source = "if_many",
      },
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
    -- Keymaps
    ------------------------------------------------------------------
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),

      callback = function(ev)
        local opts = { buffer = ev.buf, silent = true }

        local map = function(mode, lhs, rhs, desc)
          opts.desc = desc
          vim.keymap.set(mode, lhs, rhs, opts)
        end

        -- Navigation
        map("n", "gd", vim.lsp.buf.definition, "Go to definition")
        map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
        map("n", "gr", vim.lsp.buf.references, "References")
        map("n", "gi", vim.lsp.buf.implementation, "Implementation")
        map("n", "K", vim.lsp.buf.hover, "Hover")
        map("n", "<leader>D", vim.lsp.buf.type_definition, "Type definition")

        -- Actions
        map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
        map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")

        -- Diagnostics
        map("n", "gl", vim.diagnostic.open_float, "Line diagnostics")
        map("n", "[d", function()
          vim.diagnostic.jump({ count = -1, float = true })
        end, "Previous diagnostic")

        map("n", "]d", function()
          vim.diagnostic.jump({ count = 1, float = true })
        end, "Next diagnostic")

        map("n", "gld", vim.diagnostic.setloclist, "Buffer diagnostics")
        map("n", "gLd", vim.diagnostic.setqflist, "Workspace diagnostics")

        -- Signature
        map("i", "<C-k>", vim.lsp.buf.signature_help, "Signature help")
      end,
    })

    ------------------------------------------------------------------
    -- Lua
    ------------------------------------------------------------------
    vim.lsp.config("lua_ls", {
      settings = {
        Lua = {
          diagnostics = {
            globals = { "vim" },
          },
          completion = {
            callSnippet = "Replace",
          },
          workspace = {
            checkThirdParty = false,
            library = vim.api.nvim_get_runtime_file("", true),
          },
          telemetry = {
            enable = false,
          },
          format = {
            enable = false,
          },
        },
      },
    })
    vim.lsp.enable("lua_ls")

    ------------------------------------------------------------------
    -- Python: Pyright
    ------------------------------------------------------------------
    vim.lsp.config("pyright", {
      capabilities = vim.tbl_deep_extend("force", capabilities, {
        offsetEncoding = { "utf-8" },
      }),
      settings = {
        python = {
          analysis = {
            typeCheckingMode = "standard",
            diagnosticMode = "workspace",
            autoSearchPaths = true,
            useLibraryCodeForTypes = true,
            autoImportCompletions = true,
            reportMissingTypeStubs = false,
          },
        },
      },
    })
    vim.lsp.enable("pyright")

    ------------------------------------------------------------------
    -- Python: Ruff
    ------------------------------------------------------------------
    vim.lsp.config("ruff", {
      on_attach = function(client)
        client.server_capabilities.hoverProvider = false
      end,
      init_options = {
        settings = {
          lint = {
            select = {
              "E",
              "F",
              "W",
              "I",
              "B",
              "UP",
              "SIM",
            },
          },
          format = {
            preview = false,
          },
        },
      },
    })
    vim.lsp.enable("ruff")

    ------------------------------------------------------------------
    -- Bash
    ------------------------------------------------------------------
    vim.lsp.enable("bashls")

    ------------------------------------------------------------------
    -- C / C++
    ------------------------------------------------------------------
    vim.lsp.config("clangd", {
      cmd = {
        "clangd",
        "--background-index",
        "--clang-tidy",
        "--completion-style=detailed",
        "--cross-file-rename",
        "--header-insertion=iwyu",
        "--fallback-style=llvm",
      },
    })
    vim.lsp.enable("clangd")

    ------------------------------------------------------------------
    -- Go
    ------------------------------------------------------------------
    vim.lsp.config("gopls", {
      settings = {
        gopls = {
          analyses = {
            unusedparams = true,
            nilness = true,
            unusedwrite = true,
            useany = true,
            shadow = true,
          },
          staticcheck = true,
          gofumpt = true,
          usePlaceholders = true,
          completeUnimported = true,
        },
      },
    })
    vim.lsp.enable("gopls")

    ------------------------------------------------------------------
    -- Rust
    ------------------------------------------------------------------
    vim.lsp.config("rust_analyzer", {
      settings = {
        ["rust-analyzer"] = {
          cargo = {
            allFeatures = true,
          },
          checkOnSave = true,
          check = {
            command = "clippy",
          },
        },
      },
    })
    vim.lsp.enable("rust_analyzer")

    ------------------------------------------------------------------
    -- Markdown
    ------------------------------------------------------------------
    vim.lsp.enable("marksman")

    ------------------------------------------------------------------
    -- YAML
    ------------------------------------------------------------------
    vim.lsp.enable("yamlls")

    ------------------------------------------------------------------
    -- TOML
    ------------------------------------------------------------------
    vim.lsp.enable("taplo")

    ------------------------------------------------------------------
    -- HTML
    ------------------------------------------------------------------
    vim.lsp.enable("html")

    ------------------------------------------------------------------
    -- TailwindCSS
    ------------------------------------------------------------------
    vim.lsp.enable("tailwindcss")
  end,
}
