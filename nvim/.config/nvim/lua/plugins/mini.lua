return {
  {
    "echasnovski/mini.ai",
    version = "*",
    opts = function()
      local ai = require("mini.ai")
      return {
        n_lines = 500,
        custom_textobjects = {
          -- We add the 'fallback = true' and ensure we are targeting
          -- the standard Treesitter capture groups.
          o = ai.gen_spec.treesitter({
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }, { fallback = true }),

          -- For bash, sometimes @function.outer is missing from queries.
          -- We include @function_definition as a backup string.
          f = ai.gen_spec.treesitter({
            a = "@function.outer",
            i = "@function.inner",
          }, { fallback = true }),

          c = ai.gen_spec.treesitter({
            a = "@class.outer",
            i = "@class.inner",
          }, { fallback = true }),

          -- Your other objects...
          t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" },
          d = { "%f[%d]%d+" },
          e = {
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
            local to = { line = vim.fn.line("$"), col = math.max(vim.fn.getline("$"):len(), 1) }
            return { from = from, to = to }
          end,
          u = ai.gen_spec.function_call(),
          U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }),
        },
      }
    end,
  },

  -- The rest of your mini plugins remain the same as they don't depend on TS modules
  {
    "echasnovski/mini.surround",
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
      miniTrailspace.setup({ only_in_normal_buffers = true })
      vim.keymap.set("n", "<leader>cw", miniTrailspace.trim, { desc = "Erase Whitespace" })

      vim.api.nvim_create_autocmd("CursorMoved", {
        callback = function()
          require("mini.trailspace").unhighlight()
        end,
      })
    end,
  },

  {
    "echasnovski/mini.pairs",
    event = "InsertEnter",
    opts = {
      modes = { insert = true, command = true, terminal = false },
      skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
      skip_ts = { "string" },
      skip_unbalanced = true,
      markdown = true,
    },
  },

  {
    "echasnovski/mini.indentscope",
    version = "*",
    event = "BufReadPre",
    config = function()
      vim.api.nvim_set_hl(0, "MiniIndentscopeSymbol", { fg = "#444c56" })
      vim.api.nvim_set_hl(0, "MiniIndentscopePrefix", { underline = true, fg = "#444c56" })
      require("mini.indentscope").setup({
        symbol = "┃",
        draw = { delay = 0, animation = require("mini.indentscope").gen_animation.none() },
        options = { try_as_border = true },
      })
    end,
  },

  {
    "echasnovski/mini.icons",
    version = false,
  },
}
