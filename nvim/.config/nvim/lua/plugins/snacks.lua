return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,

    opts = {
      ----------------------------------------------------------------
      -- Core UI
      ----------------------------------------------------------------
      notifier = {
        enabled = true,
        timeout = 3000,
      },

      input = {
        enabled = true,
      },

      quickfile = {
        enabled = true,
        exclude = { "latex" },
      },

      ----------------------------------------------------------------
      -- Editing / Utilities
      ----------------------------------------------------------------
      rename = {
        enabled = true,
      },

      scratch = {
        enabled = true,
      },

      scope = {
        enabled = true,
      },

      toggle = {
        enabled = true,
      },

      words = {
        enabled = true,

        debounce = 100,

        notify_jump = true,

        modes = { "n", "i", "c" },
      },

      ----------------------------------------------------------------
      -- Bigfile
      ----------------------------------------------------------------
      bigfile = {
        enabled = true,

        notify = true,

        size = 1.5 * 1024 * 1024,

        line_length = 1000,

        setup = function(ctx)
          vim.schedule(function()
            vim.bo[ctx.buf].syntax = ctx.ft
          end)

          vim.treesitter.stop(ctx.buf)

          vim.bo[ctx.buf].swapfile = false
          vim.bo[ctx.buf].undofile = false
          vim.bo[ctx.buf].foldmethod = "manual"

          vim.diagnostic.enable(false, { bufnr = ctx.buf })
        end,
      },

      ----------------------------------------------------------------
      -- Statuscolumn
      ----------------------------------------------------------------
      statuscolumn = {
        enabled = false,

        -- left = {
        --   "mark",
        --   "sign",
        -- },
        --
        -- right = {
        --   "git",
        --   "fold",
        -- },
        --
        -- folds = {
        --   open = true,
        --   git_hl = true,
        -- },
        --
        -- git = {
        --   patterns = {
        --     "GitSign",
        --     "MiniDiffSign",
        --     "Oil",
        --     "Diagnostic",
        --     "Dap",
        --   },
        -- },
        --
        -- refresh = 50,
      },

      ----------------------------------------------------------------
      -- Image Support
      ----------------------------------------------------------------
      image = {
        enabled = true,

        doc = {
          inline = true,
          float = true,
          max_width = 80,
          max_height = 40,
        },

        img_dirs = {
          "img",
          "images",
          "assets",
          "static",
          "public",
        },

        math = {
          enabled = true,
        },

        convert = {
          notify = false,
        },

        cache = vim.fn.stdpath("cache") .. "/snacks/image",

        debug = {
          request = false,
          convert = false,
        },
      },

      ----------------------------------------------------------------
      -- Zen
      ----------------------------------------------------------------
      zen = {
        enabled = true,

        toggles = {
          dim = true,
          git_signs = false,
          mini_diff_signs = false,
          diagnostics = false,
          inlay_hints = false,
        },

        show = {
          statusline = false,
          tabline = false,
        },
      },

      ----------------------------------------------------------------
      -- Picker
      ----------------------------------------------------------------
      picker = {
        enabled = true,

        ui_select = true,

        matcher = {
          fuzzy = true,
          smartcase = true,
          ignorecase = true,
          sort_empty = false,
          filename_bonus = true,
        },

        matchers = {
          frecency = true,
          cwd_bonus = true,
        },

        formatters = {
          file = {
            filename_first = false,
            truncate = 80,
            icon_width = 2,
          },
        },

        win = {
          input = {
            keys = {
              ["<Esc>"] = { "close", mode = { "n", "i" } },
              ["<C-u>"] = { "preview_scroll_up", mode = { "i", "n" } },
              ["<C-d>"] = { "preview_scroll_down", mode = { "i", "n" } },
            },
          },
        },

        layout = {
          preset = "telescope",
          cycle = false,
        },

        layouts = {
          select = {
            preview = false,

            layout = {
              backdrop = false,
              width = 0.6,
              min_width = 80,
              height = 0.4,
              min_height = 10,
              box = "vertical",
              border = "rounded",
              title = "{title}",
              title_pos = "center",

              { win = "input", height = 1, border = "bottom" },
              { win = "list", border = "none" },

              {
                win = "preview",
                title = "{preview}",
                width = 0.6,
                height = 0.4,
                border = "top",
              },
            },
          },

          telescope = {
            reverse = true,

            layout = {
              box = "horizontal",
              backdrop = false,
              width = 0.90,
              height = 0.90,
              border = "none",

              {
                box = "vertical",

                {
                  win = "list",
                  title = " Results ",
                  title_pos = "center",
                  border = "rounded",
                },

                {
                  win = "input",
                  height = 1,
                  border = "rounded",
                  title = "{title} {live} {flags}",
                  title_pos = "center",
                },
              },

              {
                win = "preview",
                title = "{preview:Preview}",
                width = 0.55,
                border = "rounded",
                title_pos = "center",
              },
            },
          },

          ivy = {
            layout = {
              box = "vertical",
              backdrop = false,
              width = 0,
              height = 0.4,
              position = "bottom",
              border = "top",
              title = " {title} {live} {flags}",
              title_pos = "left",

              { win = "input", height = 1, border = "bottom" },

              {
                box = "horizontal",
                { win = "list", border = "none" },

                {
                  win = "preview",
                  title = "{preview}",
                  width = 0.5,
                  border = "left",
                },
              },
            },
          },
        },
      },

      ----------------------------------------------------------------
      -- Dashboard
      ----------------------------------------------------------------
      dashboard = {
        enabled = true,

        preset = {
          header = [[
███╗   ██╗██╗   ██╗██╗███╗   ███╗
████╗  ██║██║   ██║██║████╗ ████║
██╔██╗ ██║██║   ██║██║██╔████╔██║
██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝
          ]],
        },

        sections = {
          { section = "header" },

          {
            section = "keys",
            gap = 1,
            padding = 1,
          },

          {
            icon = " ",
            title = "Recent Files",
            section = "recent_files",
            indent = 2,
            padding = 1,
          },

          {
            icon = " ",
            title = "Projects",
            section = "projects",
            indent = 2,
            padding = 1,
          },

          {
            section = "startup",
          },

          {
            section = "terminal",
            cmd = "colorscript random",
            random = 10,
            pane = 2,
            indent = 4,
            height = 20,
          },
        },
      },
    },

    keys = {
      ----------------------------------------------------------------
      -- Git
      ----------------------------------------------------------------
      {
        "<leader>gg",
        function()
          require("snacks").lazygit()
        end,
        desc = "Lazygit",
      },

      {
        "<leader>gL",
        function()
          require("snacks").lazygit.log()
        end,
        desc = "Lazygit Logs",
      },

      ----------------------------------------------------------------
      -- Rename
      ----------------------------------------------------------------
      {
        "<leader>rN",
        function()
          require("snacks").rename.rename_file()
        end,
        desc = "Rename Current File",
      },

      ----------------------------------------------------------------
      -- Picker
      ----------------------------------------------------------------
      {
        "<leader>ff",
        function()
          require("snacks").picker.files({
            cwd = vim.fn.getcwd(), -- Locks the search strictly to your PWD
            hidden = true, -- Shows hidden files (e.g., .env, .bashrc)
            ignored = true, -- Shows files ignored by .gitignore
            follow = true, -- Follows symlinks
            exclude = { ".git/" }, -- Optional: keeps the search clean by hiding raw git history files
          })
        end,
        desc = "Find Files",
      },

      {
        "<leader>fr",
        function()
          require("snacks").picker.recent()
        end,
        desc = "Recent Files",
      },

      {
        "<leader>fb",
        function()
          require("snacks").picker.buffers()
        end,
        desc = "Buffers",
      },

      {
        "<leader>fs",
        function()
          require("snacks").picker.grep({
            hidden = true,
            ignored = true,
          })
        end,
        desc = "Live Grep",
      },

      {
        "<leader>fw",
        function()
          require("snacks").picker.grep_word({
            hidden = true,
            ignored = true,
          })
        end,
        mode = { "n", "x" },
        desc = "Search Word",
      },

      {
        "<leader>fk",
        function()
          require("snacks").picker.keymaps({
            layout = "ivy",
          })
        end,
        desc = "Search Keymaps",
      },

      {
        "<leader>fh",
        function()
          require("snacks").picker.help()
        end,
        desc = "Help Pages",
      },

      {
        "<leader>gbr",
        function()
          require("snacks").picker.git_branches({
            layout = "select",
          })
        end,
        desc = "Git Branches",
      },

      ----------------------------------------------------------------
      -- Zen
      ----------------------------------------------------------------
      {
        "<leader>uz",
        function()
          require("snacks").zen()
        end,
        desc = "Zen Mode",
      },

      ----------------------------------------------------------------
      -- Scratch
      ----------------------------------------------------------------
      {
        "<leader>us",
        function()
          require("snacks").scratch()
        end,
        desc = "Scratch Buffer",
      },

      ----------------------------------------------------------------
      -- Image
      ----------------------------------------------------------------
      {
        "<leader>ui",
        function()
          require("snacks.image").hover()
        end,
        desc = "Image Hover",
      },
    },
  },

  --------------------------------------------------------------------
  -- Todo Comments Integration
  --------------------------------------------------------------------
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPre", "BufNewFile" },
    optional = true,

    keys = {
      {
        "<leader>ft",
        function()
          require("snacks").picker.todo_comments()
        end,
        desc = "Todo",
      },

      {
        "<leader>fT",
        function()
          require("snacks").picker.todo_comments({
            keywords = { "TODO", "FIX", "FIXME" },
          })
        end,
        desc = "Todo/Fix/Fixme",
      },
    },
  },
}
