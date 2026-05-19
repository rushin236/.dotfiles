return {
  {
    "MagicDuck/grug-far.nvim",
    opts = {
      engines = {
        ripgrep = {
          extraArgs = "--hidden --glob !.git --glob !.vscode --glob !.idea --glob !.DS_Store",
        },
      },

      keymaps = {
        ----------------------------------------------------------------
        -- Help
        ----------------------------------------------------------------
        help = {
          n = "<leader>r?",
        },

        ----------------------------------------------------------------
        -- Replace
        ----------------------------------------------------------------
        replace = {
          n = "<leader>rr",
        },

        ----------------------------------------------------------------
        -- Sync
        ----------------------------------------------------------------
        syncLocations = {
          n = "<leader>ra",
        },

        syncLine = {
          n = "<leader>rl",
        },

        syncNext = {
          n = "<leader>rn",
        },

        syncPrev = {
          n = "<leader>rp",
        },

        syncFile = {
          n = "<leader>rF",
        },

        ----------------------------------------------------------------
        -- Navigation
        ----------------------------------------------------------------
        -- gotoLocation = {
        --   n = "<leader>r<CR>", -- Updated to start with <leader>r
        -- },

        openLocation = {
          n = "<leader>ro",
        },

        ----------------------------------------------------------------
        -- Apply
        ----------------------------------------------------------------
        applyNext = {
          n = "<leader>rj",
        },

        applyPrevious = {
          n = "<leader>rk",
        },

        ----------------------------------------------------------------
        -- History
        ----------------------------------------------------------------
        historyOpen = {
          n = "<leader>rh",
        },

        historyAdd = {
          n = "<leader>rA",
        },

        ----------------------------------------------------------------
        -- Tools
        ----------------------------------------------------------------
        refresh = {
          n = "<leader>rR",
        },

        qfList = {
          n = "<leader>rq",
        },

        previewLocation = {
          n = "<leader>ri",
        },

        ----------------------------------------------------------------
        -- Toggles
        ----------------------------------------------------------------
        swapEngine = {
          n = "<leader>re",
        },

        toggleShowCommand = {
          n = "<leader>rc",
        },

        swapReplacementInterpreter = {
          n = "<leader>rx",
        },

        ----------------------------------------------------------------
        -- Session
        ----------------------------------------------------------------
        abort = {
          n = "<leader>rb",
        },

        close = {
          n = "<leader>rC",
        },

        ----------------------------------------------------------------
        -- Inputs
        ----------------------------------------------------------------
        -- nextInput = {
        --   n = "<leader>r<Tab>", -- Updated to start with <leader>r
        -- },
        --
        -- prevInput = {
        --   n = "<leader>r<S-Tab>", -- Updated to start with <leader>r
        -- },
      },
    },

    keys = {
      ----------------------------------------------------------------
      -- Open / Toggle Replace
      ----------------------------------------------------------------
      {
        "<leader>rg", -- Changed from <leader>r to avoid prefix conflict
        function()
          require("grug-far").toggle_instance({ instanceName = "grug-far" })
        end,
        desc = "Toggle Replace",
      },

      ----------------------------------------------------------------
      -- Replace Current Word
      ----------------------------------------------------------------
      {
        "<leader>rw",
        function()
          require("grug-far").open({
            prefills = {
              search = vim.fn.expand("<cword>"),
            },
          })
        end,
        desc = "Replace Current Word",
      },

      ----------------------------------------------------------------
      -- Replace In Current File
      ----------------------------------------------------------------
      {
        "<leader>rf",
        function()
          require("grug-far").open({
            prefills = {
              paths = vim.fn.expand("%"),
            },
          })
        end,
        desc = "Replace In File",
      },

      ----------------------------------------------------------------
      -- Replace Visual Selection
      ----------------------------------------------------------------
      {
        mode = "v",
        "<leader>rv",
        function()
          local text = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."))

          require("grug-far").open({
            prefills = {
              search = table.concat(text, "\n"),
            },
          })
        end,
        desc = "Replace Visual Selection",
      },
    },
  },
}
