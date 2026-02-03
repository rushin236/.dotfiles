return {
  -- Mini.ai (around/inner)
  {
    "nvim-mini/mini.ai",
    version = "*",
    opts = function()
      local ai = require("mini.ai")
      return {
        n_lines = 500,
        custom_textobjects = {
          o = ai.gen_spec.treesitter({ -- code block
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }),
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }), -- function
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }), -- class
          t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" }, -- tags
          d = { "%f[%d]%d+" }, -- digits
          e = { -- Word with case
            {
              "%u[%l%d]+%f[^%l%d]",
              "%f[%S][%l%d]+%f[^%l%d]",
              "%f[%P][%l%d]+%f[^%l%d]",
              "^[%l%d]+%f[^%l%d]",
            },
            "^().*()$",
          },
          g = function()
            local from = { line = 1, col = 1 }
            local to = {
              line = vim.fn.line("$"),
              col = math.max(vim.fn.getline("$"):len(), 1),
            }
            return { from = from, to = to }
          end, -- buffer
          u = ai.gen_spec.function_call(), -- u for "Usage"
          U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }), -- without dot in function name
        },
      }
    end,
  },

  -- MiniFiles
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

  -- miniTrailspace
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

  -- MiniPairs
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

  -- MiniIndentscope
  {
    "nvim-mini/mini.indentscope",
    version = "*",
    event = "BufReadPre",
    config = function()
      -- Vertical scope line (thicker)
      vim.api.nvim_set_hl(0, "MiniIndentscopeSymbol", {
        fg = "#444c56",
      })

      -- Start of current indent scope (underline)
      vim.api.nvim_set_hl(0, "MiniIndentscopePrefix", {
        underline = true,
        fg = "#444c56",
      })

      require("mini.indentscope").gen_animation.none()

      require("mini.indentscope").setup({
        symbol = "┃", -- thicker line
        draw = {
          delay = 0, -- no animation
        },
        options = {
          try_as_border = true,
        },
      })
    end,
  },
}
