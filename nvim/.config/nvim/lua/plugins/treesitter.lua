return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    event = { "BufReadPre", "BufNewFile" },
    build = ":TSUpdate",
    dependencies = {
      {
        "nvim-treesitter/nvim-treesitter-textobjects",
        branch = "master",
      },
      "windwp/nvim-ts-autotag",
    },
    config = function()
      require("nvim-treesitter.configs").setup({
        highlight = {
          enable = true,
        },

        indent = {
          enable = true,
        },

        ensure_installed = {
          "bash",
          "c",
          "cpp",
          "rust",
          "diff",
          "html",
          "css",
          "javascript",
          "json",
          "lua",
          "markdown",
          "python",
          "query",
          "regex",
          "toml",
          "typescript",
          "vim",
          "yaml",
        },

        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<C-space>",
            node_incremental = "<C-space>",
          },
        },

        textobjects = {
          move = {
            enable = true,
            set_jumps = true,

            goto_next_start = {
              ["]f"] = "@function.outer",
              ["]c"] = "@class.outer",
            },
            goto_next_end = {
              ["]F"] = "@function.outer",
              ["]C"] = "@class.outer",
            },
            goto_previous_start = {
              ["[f"] = "@function.outer",
              ["[c"] = "@class.outer",
            },
            goto_previous_end = {
              ["[F"] = "@function.outer",
              ["[C"] = "@class.outer",
            },
          },
        },

        additional_vim_regex_highlighting = false,
      })
    end,
  },

  {
    "windwp/nvim-ts-autotag",
    lazy = true,
    ft = {
      "html",
      "xml",
      "javascript",
      "typescript",
      "javascriptreact",
      "typescriptreact",
      "svelte",
    },
    config = function()
      require("nvim-ts-autotag").setup()
    end,
  },
}
