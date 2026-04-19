return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  build = ":TSUpdate",
  lazy = false,
  dependencies = {
    "windwp/nvim-ts-autotag",
    {
      "nvim-treesitter/nvim-treesitter-textobjects",
      branch = "main",
      config = function()
        -- 1. Setup Textobjects specific features
        require("nvim-treesitter-textobjects").setup({
          select = {
            -- lookahead allows jumping forward to the next text object if your cursor isn't currently inside one
            lookahead = true,
          },
        })

        ------------------------------------------------------------------
        -- SELECT MAPPINGS
        -- (Commented out because mini.ai handles these automatically!)
        ------------------------------------------------------------------
        -- local select = require("nvim-treesitter-textobjects.select")
        -- local select_maps = {
        --   ["af"] = "@function.outer", ["if"] = "@function.inner",
        --   ["ac"] = "@class.outer",    ["ic"] = "@class.inner",
        --   ["al"] = "@loop.outer",     ["il"] = "@loop.inner",
        --   ["ai"] = "@conditional.outer", ["ii"] = "@conditional.inner",
        --   ["ab"] = "@block.outer",    ["ib"] = "@block.inner",
        --   ["ap"] = "@parameter.outer", ["ip"] = "@parameter.inner",
        -- }
        -- for key, query in pairs(select_maps) do
        --   vim.keymap.set({ "x", "o" }, key, function()
        --     select.select_textobject(query, "textobjects")
        --   end, { desc = "Select " .. query })
        -- end

        ------------------------------------------------------------------
        -- MOVE MAPPINGS
        ------------------------------------------------------------------
        local move = require("nvim-treesitter-textobjects.move")

        -- Jump to Next Start
        local next_start = {
          ["]f"] = "@function.outer",
          ["]c"] = "@class.outer",
          ["]l"] = "@loop.outer",
          ["]i"] = "@conditional.outer",
        }
        for key, query in pairs(next_start) do
          vim.keymap.set({ "n", "x", "o" }, key, function()
            move.goto_next_start(query, "textobjects")
          end, { desc = "Next start " .. query })
        end

        -- Jump to Previous Start
        local prev_start = {
          ["[f"] = "@function.outer",
          ["[c"] = "@class.outer",
          ["[l"] = "@loop.outer",
          ["[i"] = "@conditional.outer",
        }
        for key, query in pairs(prev_start) do
          vim.keymap.set({ "n", "x", "o" }, key, function()
            move.goto_previous_start(query, "textobjects")
          end, { desc = "Prev start " .. query })
        end

        -- Jump to Next End
        local next_end = {
          ["]F"] = "@function.outer",
          ["]C"] = "@class.outer",
        }
        for key, query in pairs(next_end) do
          vim.keymap.set({ "n", "x", "o" }, key, function()
            move.goto_next_end(query, "textobjects")
          end, { desc = "Next end " .. query })
        end

        -- Jump to Previous End
        local prev_end = {
          ["[F"] = "@function.outer",
          ["[C"] = "@class.outer",
        }
        for key, query in pairs(prev_end) do
          vim.keymap.set({ "n", "x", "o" }, key, function()
            move.goto_previous_end(query, "textobjects")
          end, { desc = "Prev end " .. query })
        end
      end,
    },
  },
  config = function()
    local ts = require("nvim-treesitter")

    -- Explicitly list parsers
    local parsers = {
      "bash",
      "c",
      "cpp",
      "css",
      "diff",
      "go",
      "html",
      "javascript",
      "json",
      "lua",
      "markdown",
      "markdown_inline",
      "python",
      "query",
      "regex",
      "rust",
      "toml",
      "tsx",
      "typescript",
      "vim",
      "vimdoc",
      "yaml",
    }

    ts.install(parsers, { summary = false })

    -- Native Treesitter highlighting startup
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("TreesitterStartup", { clear = true }),
      pattern = "*",
      callback = function(args)
        local ft = vim.bo[args.buf].filetype
        local lang = vim.treesitter.language.get_lang(ft) or ft
        pcall(vim.treesitter.start, args.buf, lang)
        vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })

    require("nvim-ts-autotag").setup()
  end,
}
