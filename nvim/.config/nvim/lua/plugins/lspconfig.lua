return {
  "neovim/nvim-lspconfig",

  event = { "BufReadPre", "BufNewFile" },

  dependencies = {
    { "antosha417/nvim-lsp-file-operations", config = true },
    "saghen/blink.cmp",
  },

  config = function()
    ------------------------------------------------------------------
    -- LSP Logging
    ------------------------------------------------------------------
    vim.lsp.log.set_level(vim.log.levels.ERROR)

    ------------------------------------------------------------------
    -- Capabilities
    ------------------------------------------------------------------
    local capabilities = require("blink.cmp").get_lsp_capabilities()

    vim.lsp.config("*", {
      capabilities = capabilities,
    })

    ------------------------------------------------------------------
    -- Diagnostics UI
    ------------------------------------------------------------------
    vim.diagnostic.config({
      virtual_text = {
        spacing = 2,
        source = "if_many",
      },

      underline = true,
      update_in_insert = false,
      severity_sort = true,
      signs = true,

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
    -- LSP Restart Helper
    ------------------------------------------------------------------
    local function restart_lsp(name)
      for _, client in ipairs(vim.lsp.get_clients()) do
        if client.name == name then
          client:stop(true)
        end
      end

      vim.defer_fn(function()
        vim.cmd("edit")
      end, 100)
    end

    vim.api.nvim_create_user_command("LspRestart", function(opts)
      local target = opts.args

      if target ~= "" then
        restart_lsp(target)
      else
        for _, client in ipairs(vim.lsp.get_clients()) do
          client:stop(true)
        end

        vim.defer_fn(function()
          vim.cmd("edit")
        end, 100)
      end
    end, {
      nargs = "?",

      complete = function()
        return vim.tbl_map(function(c)
          return c.name
        end, vim.lsp.get_clients())
      end,
    })

    ------------------------------------------------------------------
    -- LSP Attach
    ------------------------------------------------------------------
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),

      callback = function(ev)
        local opts = {
          buffer = ev.buf,
          silent = true,
        }

        ----------------------------------------------------------------
        -- Disable formatting for selected LSPs
        ----------------------------------------------------------------
        local client = vim.lsp.get_client_by_id(ev.data.client_id)

        if client then
          local disable_formatting = {
            tsserver = true,
            html = true,
            jsonls = true,
            yamlls = true,
          }

          if disable_formatting[client.name] then
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
          end
        end

        ----------------------------------------------------------------
        -- Inlay Hints
        ----------------------------------------------------------------
        if vim.lsp.inlay_hint then
          vim.lsp.inlay_hint.enable(true, {
            bufnr = ev.buf,
          })
        end

        local map = function(mode, lhs, rhs, desc)
          opts.desc = desc
          vim.keymap.set(mode, lhs, rhs, opts)
        end

        ----------------------------------------------------------------
        -- Navigation
        ----------------------------------------------------------------
        map("n", "gd", vim.lsp.buf.definition, "Go to definition")
        map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
        map("n", "gr", vim.lsp.buf.references, "References")
        map("n", "gi", vim.lsp.buf.implementation, "Implementation")
        map("n", "gt", vim.lsp.buf.type_definition, "Type definition")
        map("n", "K", vim.lsp.buf.hover, "Hover documentation")

        ----------------------------------------------------------------
        -- Actions
        ----------------------------------------------------------------
        map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")

        map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")

        ----------------------------------------------------------------
        -- Diagnostics
        ----------------------------------------------------------------
        map("n", "gl", vim.diagnostic.open_float, "Line diagnostics")

        map("n", "[d", function()
          vim.diagnostic.jump({
            count = -1,
            float = true,
          })
        end, "Previous diagnostic")

        map("n", "]d", function()
          vim.diagnostic.jump({
            count = 1,
            float = true,
          })
        end, "Next diagnostic")

        map("n", "<leader>dl", vim.diagnostic.setloclist, "Buffer diagnostics")

        map("n", "<leader>dq", vim.diagnostic.setqflist, "Workspace diagnostics")

        ----------------------------------------------------------------
        -- Signature Help
        ----------------------------------------------------------------
        map("i", "<C-k>", vim.lsp.buf.signature_help, "Signature help")

        ----------------------------------------------------------------
        -- Workspace
        ----------------------------------------------------------------
        map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, "Add workspace folder")

        map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, "Remove workspace folder")

        map("n", "<leader>wl", function()
          print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, "List workspace folders")
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

            library = {
              vim.env.VIMRUNTIME,
              "${3rd}/luv/library",
              "${3rd}/busted/library",
              unpack(vim.api.nvim_get_runtime_file("", true)),
            },
          },

          telemetry = {
            enable = false,
          },

          format = {
            enable = false,
          },

          hint = {
            enable = true,
            semicolon = "Disable",
          },

          codeLens = {
            enable = true,
          },
        },
      },
    })

    vim.lsp.enable("lua_ls")

    ------------------------------------------------------------------
    -- Python: BasedPyright
    ------------------------------------------------------------------
    vim.lsp.config("basedpyright", {
      capabilities = vim.tbl_deep_extend("force", capabilities, {
        offsetEncoding = { "utf-8" },
      }),

      settings = {
        basedpyright = {
          analysis = {
            autoSearchPaths = true,
            diagnosticMode = "openFilesOnly",
          },
        },

        python = {
          analysis = {
            typeCheckingMode = "standard",
            diagnosticMode = "workspace",
            autoSearchPaths = true,
            useLibraryCodeForTypes = true,
            autoImportCompletions = true,
            reportMissingTypeStubs = false,

            inlayHints = {
              variableTypes = true,
              functionReturnTypes = true,
              callArgumentNames = true,
            },
          },
        },
      },
    })

    vim.lsp.enable("basedpyright")

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
    vim.lsp.config("bashls", {
      settings = {
        bashIde = {
          globPattern = "*@(.sh|.inc|.bash|.command)",
        },
      },
    })

    vim.lsp.enable("bashls")

    ------------------------------------------------------------------
    -- C / C++
    ------------------------------------------------------------------
    vim.lsp.config("clangd", {
      capabilities = vim.tbl_deep_extend("force", capabilities, {
        offsetEncoding = { "utf-8", "utf-16" },
      }),

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
      filetypes = {
        "go",
        "gomod",
        "gowork",
        "gotmpl",
      },

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

          check = {
            command = "clippy",
          },

          lens = {
            enable = true,

            debug = {
              enable = true,
            },

            implementations = {
              enable = true,
            },

            references = {
              adt = {
                enable = true,
              },

              enumVariant = {
                enable = true,
              },

              method = {
                enable = true,
              },

              trait = {
                enable = true,
              },
            },

            run = {
              enable = true,
            },

            updateTest = {
              enable = true,
            },
          },
        },
      },
    })

    vim.lsp.enable("rust_analyzer")

    ------------------------------------------------------------------
    -- Markdown
    ------------------------------------------------------------------
    vim.lsp.config("marksman", {
      filetypes = {
        "markdown",
        "mdx",
      },
    })

    vim.lsp.enable("marksman")

    ------------------------------------------------------------------
    -- YAML
    ------------------------------------------------------------------
    vim.lsp.config("yamlls", {
      filetypes = {
        "yaml",
        "yaml.docker-compose",
        "yaml.gitlab",
        "yaml.helm-values",
      },

      settings = {
        redhat = {
          telemetry = {
            enabled = false,
          },
        },

        yaml = {
          format = {
            enable = true,
          },
        },
      },
    })

    vim.lsp.enable("yamlls")

    ------------------------------------------------------------------
    -- TOML
    ------------------------------------------------------------------
    vim.lsp.enable("taplo")

    ------------------------------------------------------------------
    -- HTML
    ------------------------------------------------------------------
    vim.lsp.config("html", {
      filetypes = {
        "html",
      },
    })

    vim.lsp.enable("html")

    ------------------------------------------------------------------
    -- TailwindCSS
    ------------------------------------------------------------------
    vim.lsp.config("tailwindcss", {
      filetypes = {
        "html",
        "css",
        "scss",
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "vue",
        "svelte",
        "templ",
        "markdown",
        "mdx",
      },

      settings = {
        tailwindCSS = {
          classAttributes = {
            "class",
            "className",
            "class:list",
            "classList",
            "ngClass",
          },

          lint = {
            cssConflict = "warning",
            invalidApply = "error",
            invalidConfigPath = "error",
            invalidScreen = "error",
            invalidTailwindDirective = "error",
            invalidVariant = "error",
            recommendedVariantOrder = "warning",
          },

          validate = true,
        },
      },
    })

    vim.lsp.enable("tailwindcss")
  end,
}
