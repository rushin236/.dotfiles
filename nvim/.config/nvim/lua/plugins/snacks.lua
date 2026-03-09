return {
  -- HACK: docs @ https://github.com/folke/snacks.nvim/blob/main/docs
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,

    opts = {
      -- Core UI improvements
      notifier = { enabled = true },
      input = { enabled = true },
      quickfile = { enabled = true, exclude = { "latex" } },

      -- Useful editing utilities
      rename = { enabled = true },
      scratch = { enabled = true },
      scope = { enabled = true },
      -- indent = { enabled = true },
      toggle = { enabled = true },

      -- UI modes
      zen = { enabled = true },

      -- Terminal integration
      -- terminal = { enabled = true },

      -- Picker (your search engine)
      picker = {
        enabled = true,

        matchers = {
          frecency = true,
          cwd_bonus = false,
        },

        formatters = {
          file = {
            filename_first = false,
            filename_only = false,
            icon_width = 2,
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
              width = 0.8,
              height = 0.9,
              border = "none",
              {
                box = "vertical",
                { win = "list", title = " Results ", title_pos = "center", border = "rounded" },
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
                width = 0.50,
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
                { win = "preview", title = "{preview}", width = 0.5, border = "left" },
              },
            },
          },
        },
      },

      dashboard = {
        enabled = true,
        sections = {
          { section = "header" },
          { section = "keys", gap = 1, padding = 1 },
          { section = "startup" },
          {
            section = "terminal",
            random = 15,
            pane = 2,
            indent = 15,
            height = 20,
          },
        },
      },
    },

    keys = {
      -- Git
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

      -- Rename file
      {
        "<leader>rN",
        function()
          require("snacks").rename.rename_file()
        end,
        desc = "Rename Current File",
      },

      -- Terminal
      -- {
      --   "<leader>tt",
      --   function()
      --     require("snacks").terminal.toggle()
      --   end,
      --   desc = "Toggle Terminal",
      -- },

      -- File search
      {
        "<leader>ff",
        function()
          require("snacks").picker.files({ hidden = true })
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
          require("snacks").picker.keymaps({ layout = "ivy" })
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

      -- Git branches
      {
        "<leader>gbr",
        function()
          require("snacks").picker.git_branches({ layout = "select" })
        end,
        desc = "Git Branches",
      },

      -- Zen mode
      {
        "<leader>uz",
        function()
          require("snacks").zen()
        end,
        desc = "Zen Mode",
      },

      -- Scratch buffer
      {
        "<leader>us",
        function()
          require("snacks").scratch()
        end,
        desc = "Scratch Buffer",
      },
    },
  },
  -- NOTE: todo comments w/ snacks
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
          require("snacks").picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME" } })
        end,
        desc = "Todo/Fix/Fixme",
      },
    },
  },
}
