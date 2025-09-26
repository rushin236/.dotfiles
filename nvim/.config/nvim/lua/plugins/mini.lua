return {
  {
    "nvim-mini/mini.ai",
    version = "*",
    config = function()
      local ai = require("mini.ai")

      require("mini.ai").setup({
        n_lines = 500,
        custom_textobjects = {
          o = ai.gen_spec.treesitter({
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }),
          f = ai.gen_spec.treesitter({
            a = "@function.outer",
            i = "@function.inner",
          }),
          c = ai.gen_spec.treesitter({
            a = "@class.outer",
            i = "@class.inner",
          }),
          t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" }, -- tags
          d = { "%f[%d]%d+" }, -- digits
          e = {
            {
              "%u[%l%d]+%f[^%l%d]",
              "%f[%S][%l%d]+%f[^%l%d]",
              "%f[%P][%l%d]+%f[^%l%d]",
              "^[%l%d]+%f[^%l%d]",
            },
            "^().*()$",
          },

          -- g = whole buffer
          g = {
            a = function()
              return {
                from = { line = 1, col = 1 },
                to = {
                  line = vim.fn.line("$"),
                  col = math.max(1, vim.fn.col({ vim.fn.line("$"), "$" })),
                },
              }
            end,
            i = function()
              return {
                from = { line = 1, col = 1 },
                to = {
                  line = vim.fn.line("$"),
                  col = math.max(1, vim.fn.col({ vim.fn.line("$"), "$" })),
                },
              }
            end,
          },

          u = ai.gen_spec.function_call(), -- "usage"
          U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }),
        },
      })
    end,
  },
  {
    "nvim-mini/mini.files",
    version = "*",
    config = function()
      local MiniFiles = require("mini.files")
      MiniFiles.setup({
        options = {
          use_as_default_explorer = false,
        },
        mappings = {
          go_in = "<CR>", -- Map both Enter and L to enter directories or open files
          go_in_plus = "l",
          go_out_plus = "h",
        },
      })
      vim.keymap.set(
        "n",
        "<leader>fm",
        "<cmd>lua MiniFiles.open()<CR>",
        { desc = "Toggle mini file explorer" }
      ) -- toggle file explorer
      vim.keymap.set("n", "<leader>fM", function()
        MiniFiles.open(vim.api.nvim_buf_get_name(0), false)
        MiniFiles.reveal_cwd()
      end, { desc = "Toggle into currently opened file" })
    end,
  },
  {
    "nvim-mini/mini.surround",
    version = "*",
    opts = {
      mappings = {
        add = "gsa",
        delete = "gsd",
        find = "gsf",
        find_left = "gsF",
        highlight = "gsh",
        replace = "gsr",
      },
    },
  },
  {
    "echasnovski/mini.trailspace",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local miniTrailspace = require("mini.trailspace")

      miniTrailspace.setup({
        only_in_normal_buffers = true,
      })
      vim.keymap.set("n", "<leader>cw", function()
        miniTrailspace.trim()
      end, { desc = "Erase Whitespace" })

      -- Ensure highlight never reappears by removing it on CursorMoved
      vim.api.nvim_create_autocmd("CursorMoved", {
        pattern = "*",
        callback = function()
          require("mini.trailspace").unhighlight()
        end,
      })
    end,
  },
  -- Split & join
  {
    "echasnovski/mini.splitjoin",
    config = function()
      local miniSplitJoin = require("mini.splitjoin")
      miniSplitJoin.setup({
        mappings = { toggle = "" }, -- Disable default mapping
      })
      vim.keymap.set({ "n", "x" }, "sj", function()
        miniSplitJoin.join()
      end, { desc = "Join arguments" })
      vim.keymap.set({ "n", "x" }, "sk", function()
        miniSplitJoin.split()
      end, { desc = "Split arguments" })
    end,
  },
  {
    "nvim-mini/mini.pairs",
    event = "InsertEnter",
    opts = {
      modes = { insert = true, command = true, terminal = false },
      -- skip autopair when next character is one of these
      skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
      -- skip autopair when the cursor is inside these treesitter nodes
      skip_ts = { "string" },
      -- skip autopair when next character is closing pair
      -- and there are more closing pairs than opening pairs
      skip_unbalanced = true,
      -- better deal with markdown code blocks
      markdown = true,
    },
  },
}
