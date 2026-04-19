return {
  "stevearc/conform.nvim",

  event = { "BufReadPre", "BufNewFile" },

  config = function()
    local conform = require("conform")

    conform.setup({
      ----------------------------------------------------------------
      -- Custom formatter config
      ----------------------------------------------------------------
      formatters = {
        --------------------------------------------------------------
        -- Only generate TOC when marker exists
        --------------------------------------------------------------
        ["markdown-toc"] = {
          condition = function(_, ctx)
            for _, line in ipairs(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)) do
              if line:find("<!%-%- toc %-%->") then
                return true
              end
            end
            return false
          end,
        },

        --------------------------------------------------------------
        -- Use system clang-format explicitly
        --------------------------------------------------------------
        ["clang-format"] = {
          command = "/usr/bin/clang-format",
        },

        --------------------------------------------------------------
        -- Shell formatter
        --------------------------------------------------------------
        shfmt = {
          prepend_args = { "-i", "2", "-ci" },
        },

        --------------------------------------------------------------
        -- Prettier (only where actually useful)
        --------------------------------------------------------------
        prettier = {
          args = {
            "--stdin-filepath",
            "$FILENAME",
            "--tab-width",
            "2",
            "--use-tabs",
            "false",
          },
        },
      },

      ----------------------------------------------------------------
      -- Formatter mapping
      ----------------------------------------------------------------
      formatters_by_ft = {
        --------------------------------------------------------------
        -- Core languages
        --------------------------------------------------------------
        lua = { "stylua" },

        python = { "ruff_fix", "ruff_format" },

        sh = { "shfmt" },
        bash = { "shfmt" },
        zsh = { "shfmt" },

        c = { "clang-format" },
        cpp = { "clang-format" },

        go = { "gofumpt" },

        rust = { "rustfmt" },

        --------------------------------------------------------------
        -- Docs / notes
        --------------------------------------------------------------
        markdown = { "markdownlint-cli2", "markdown-toc" },

        --------------------------------------------------------------
        -- Config / infra
        --------------------------------------------------------------
        yaml = { "prettier" },
        yml = { "prettier" },

        toml = { "taplo" },

        json = { "prettier" },

        --------------------------------------------------------------
        -- Python web templates
        --------------------------------------------------------------
        html = { "prettier" },
        htmldjango = { "prettier" },
        jinja = { "prettier" },
      },

      ----------------------------------------------------------------
      -- Auto format on save
      ----------------------------------------------------------------
      format_on_save = function(bufnr)
        local ignore = {
          markdown = true,
        }

        if ignore[vim.bo[bufnr].filetype] then
          return nil
        end

        return {
          lsp_fallback = true,
          async = false,
          timeout_ms = 1500,
        }
      end,
    })

    ----------------------------------------------------------------
    -- Manual format keymap
    ----------------------------------------------------------------
    vim.keymap.set({ "n", "v" }, "<leader>cf", function()
      conform.format({
        lsp_fallback = true,
        async = false,
        timeout_ms = 1500,
      })
    end, {
      desc = "Format file / selection",
    })
  end,
}
