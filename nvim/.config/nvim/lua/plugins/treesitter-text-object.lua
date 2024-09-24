return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  lazy = true,
  config = function()
    require("nvim-treesitter.configs").setup({
      textobjects = {
        select = {
          enable = true,
          lookahead = true,

          keymaps = {
            -- Custom keymaps with non-conflicting bindings
            ["<leader>ae"] = { query = "@assignment.outer", desc = "Select outer part of an assignment" },
            ["<leader>ie"] = { query = "@assignment.inner", desc = "Select inner part of an assignment" },
            ["<leader>le"] = { query = "@assignment.lhs", desc = "Select left hand side of an assignment" },
            ["<leader>re"] = { query = "@assignment.rhs", desc = "Select right hand side of an assignment" },

            -- For Javascript/Typescript files (custom capture)
            ["<leader>ao"] = { query = "@property.outer", desc = "Select outer part of an object property" },
            ["<leader>io"] = { query = "@property.inner", desc = "Select inner part of an object property" },
            ["<leader>lo"] = { query = "@property.lhs", desc = "Select left part of an object property" },
            ["<leader>ro"] = { query = "@property.rhs", desc = "Select right part of an object property" },

            -- Other keymaps
            ["<leader>ap"] = { query = "@parameter.outer", desc = "Select outer part of a parameter/argument" },
            ["<leader>ip"] = { query = "@parameter.inner", desc = "Select inner part of a parameter/argument" },

            ["<leader>ac"] = { query = "@conditional.outer", desc = "Select outer part of a conditional" },
            ["<leader>ic"] = { query = "@conditional.inner", desc = "Select inner part of a conditional" },

            ["<leader>al"] = { query = "@loop.outer", desc = "Select outer part of a loop" },
            ["<leader>il"] = { query = "@loop.inner", desc = "Select inner part of a loop" },

            ["<leader>af"] = { query = "@call.outer", desc = "Select outer part of a function call" },
            ["<leader>if"] = { query = "@call.inner", desc = "Select inner part of a function call" },

            ["<leader>am"] = { query = "@function.outer", desc = "Select outer part of a method/function definition" },
            ["<leader>im"] = { query = "@function.inner", desc = "Select inner part of a method/function definition" },

            ["<leader>ac"] = { query = "@class.outer", desc = "Select outer part of a class" },
            ["<leader>ic"] = { query = "@class.inner", desc = "Select inner part of a class" },
          },
        },
        swap = {
          enable = true,
          swap_next = {
            ["<leader>na"] = "@parameter.inner", -- swap parameters/arguments with next
            ["<leader>no"] = "@property.outer", -- swap object property with next
            ["<leader>nm"] = "@function.outer", -- swap function with next
          },
          swap_previous = {
            ["<leader>pa"] = "@parameter.inner", -- swap parameters/arguments with previous
            ["<leader>po"] = "@property.outer", -- swap object property with previous
            ["<leader>pm"] = "@function.outer", -- swap function with previous
          },
        },
        move = {
          enable = true,
          set_jumps = true, -- whether to set jumps in the jumplist
          goto_next_start = {
            ["]f"] = { query = "@call.outer", desc = "Next function call start" },
            ["]m"] = { query = "@function.outer", desc = "Next method/function def start" },
            ["]c"] = { query = "@class.outer", desc = "Next class start" },
            ["]i"] = { query = "@conditional.outer", desc = "Next conditional start" },
            ["]l"] = { query = "@loop.outer", desc = "Next loop start" },

            ["]s"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
            ["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
          },
          goto_next_end = {
            ["]F"] = { query = "@call.outer", desc = "Next function call end" },
            ["]M"] = { query = "@function.outer", desc = "Next method/function def end" },
            ["]C"] = { query = "@class.outer", desc = "Next class end" },
            ["]I"] = { query = "@conditional.outer", desc = "Next conditional end" },
            ["]L"] = { query = "@loop.outer", desc = "Next loop end" },
          },
          goto_previous_start = {
            ["[f"] = { query = "@call.outer", desc = "Prev function call start" },
            ["[m"] = { query = "@function.outer", desc = "Prev method/function def start" },
            ["[c"] = { query = "@class.outer", desc = "Prev class start" },
            ["[i"] = { query = "@conditional.outer", desc = "Prev conditional start" },
            ["[l"] = { query = "@loop.outer", desc = "Prev loop start" },
          },
          goto_previous_end = {
            ["[F"] = { query = "@call.outer", desc = "Prev function call end" },
            ["[M"] = { query = "@function.outer", desc = "Prev method/function def end" },
            ["[C"] = { query = "@class.outer", desc = "Prev class end" },
            ["[I"] = { query = "@conditional.outer", desc = "Prev conditional end" },
            ["[L"] = { query = "@loop.outer", desc = "Prev loop end" },
          },
        },
      },
    })

    local ts_repeat_move = require("nvim-treesitter.textobjects.repeatable_move")

    -- Vim way: ; goes to the direction you were moving.
    vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move)
    vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_opposite)

    -- Optionally, make builtin f, F, t, T also repeatable with ; and ,
    vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f_expr, { expr = true })
    vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F_expr, { expr = true })
    vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t_expr, { expr = true })
    vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T_expr, { expr = true })
  end,
}
