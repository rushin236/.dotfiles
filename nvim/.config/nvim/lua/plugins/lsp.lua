return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    { "antosha417/nvim-lsp-file-operations", config = true },
  },
  config = function()
    -- NOTE: LSP Keybinds
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(ev)
        -- Buffer local mappings
        local opts = { buffer = ev.buf, silent = true }

        -- Keymaps
        opts.desc = "Show LSP references"
        vim.keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)

        opts.desc = "Go to declaration"
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

        opts.desc = "Show LSP definitions"
        vim.keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)

        opts.desc = "Show LSP implementations"
        vim.keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)

        opts.desc = "Show LSP type definitions"
        vim.keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)

        opts.desc = "See available code actions"
        vim.keymap.set({ "n", "v" }, "<leader>vca", function()
          vim.lsp.buf.code_action()
        end, opts)

        opts.desc = "Smart rename"
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

        opts.desc = "Show buffer diagnostics"
        vim.keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)

        opts.desc = "Show line diagnostics"
        vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

        opts.desc = "Show documentation for what is under cursor"
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

        opts.desc = "Restart LSP"
        vim.keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)

        vim.keymap.set("i", "<C-h>", function()
          vim.lsp.buf.signature_help()
        end, opts)
      end,
    })

    -- Define sign icons for each severity
    local signs = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.HINT] = "󰠠 ",
      [vim.diagnostic.severity.INFO] = " ",
    }

    -- Set diagnostic config
    vim.diagnostic.config({
      signs = {
        text = signs,
      },
      virtual_text = true,
      underline = true,
      update_in_insert = false,
    })

    -- Setup servers
    local cmp_nvim_lsp = require("cmp_nvim_lsp")
    local capabilities = cmp_nvim_lsp.default_capabilities()

    -- Global LSP settings (applied to all servers)
    vim.lsp.config("*", {
      capabilities = capabilities,
    })

    -- Configure and enable LSP servers
    -- lua_ls
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
            library = {
              [vim.fn.expand("$VIMRUNTIME/lua")] = true,
              [vim.fn.stdpath("config") .. "/lua"] = true,
            },
          },
        },
      },
    })
    vim.lsp.enable("lua_ls")

    -- eslint-lsp
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
          enable = true,
          workingDirectory = { mode = "auto" }, -- lets eslint resolve its own config
        },
      },
      single_file_support = true,
    })
    vim.lsp.enable("eslint")

    -- ts_ls (TypeScript/JavaScript)
    vim.lsp.config("ts_ls", {
      filetypes = {
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
      },
      single_file_support = true,
      init_options = {
        preferences = {
          includeCompletionsForModuleExports = true,
          includeCompletionsForImportStatements = true,
        },
      },
    })
    vim.lsp.enable("ts_ls")

    -- gopls
    vim.lsp.config("gopls", {
      settings = {
        gopls = {
          analyses = {
            unusedparams = true,
          },
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
            -- Turn on type checking: "off", "basic", or "strict"
            typeCheckingMode = "basic",

            -- Report missing imports (helps with virtual env consistency)
            diagnosticMode = "workspace", -- or "workspace"
            autoSearchPaths = true,
            useLibraryCodeForTypes = true,

            -- Extra checks
            reportUnusedImports = true,
            reportUnusedVariable = true,

            -- Indexing can speed up completion
            indexing = true,
          },
        },
      },
    })
    vim.lsp.enable("pyright")

    -- ruff
    vim.lsp.config("ruff", {
      settings = {
        -- Ruff has only a few settings exposed via LSP,
        -- since most customization (rules, ignores, formatting style)
        -- goes inside pyproject.toml or ruff.toml
        ruff = {
          -- Enable lint-only mode (no formatting, that's black's job if you want)
          lint = {
            enable = true,
          },
        },
      },
    })
    vim.lsp.enable("ruff")

    -- clangd
    vim.lsp.config("clangd", {
      cmd = {
        "clangd",
        "--background-index", -- keeps an index of your project for fast searches
        "--clang-tidy", -- run clang-tidy diagnostics
        "--completion-style=detailed", -- more detailed autocompletion info
        "--cross-file-rename", -- smarter renaming across files
        "--header-insertion=never", -- don’t auto-insert #includes (can set to “iwyu”)
      },
      settings = {
        clangd = {
          -- Example settings exposed via clangd (most config comes via cmd flags)
          fallbackFlags = { "-std=c++20" }, -- ensure a default C++ standard
          semanticHighlighting = true,
        },
      },
    })
    vim.lsp.enable("clangd")

    -- bashls
    vim.lsp.enable("bashls")
  end,
}
