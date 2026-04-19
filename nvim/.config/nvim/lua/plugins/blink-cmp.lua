return {
  {
    "milanglacier/minuet-ai.nvim",
    lazy = false,
    dependencies = { "nvim-lua/plenary.nvim" },

    config = function()
      require("minuet").setup({

        ----------------------------------------------------------------
        -- OPTION A: FIM mode (best editing)
        ----------------------------------------------------------------
        provider = "openai_fim_compatible",
        provider_options = {
          openai_fim_compatible = {
            end_point = "http://localhost:11434/v1/completions",
            -- model = "qwen2.5-coder:7b",
            model = "qwen2.5-coder:3b",
            name = "Ollama",
            stream = true,
            api_key = "TERM",
          },
        },

        ----------------------------------------------------------------
        -- OPTION B: Prefix mode (uncomment if testing DeepSeek)
        ----------------------------------------------------------------
        -- provider = "ollama",
        -- provider_options = {
        --   ollama = {
        --     end_point = "http://localhost:11434/api/generate",
        --     model = "deepseek-coder:6.7b",
        --     stream = true,
        --   },
        -- },
      })
    end,
  },
  {
    "saghen/blink.cmp",
    version = "*",
    -- build = "cargo build --release",
    dependencies = {
      "milanglacier/minuet-ai.nvim",
      {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
        build = "make install_jsregexp",
      },
    },
    opts = {
      keymap = {
        preset = "none",
        ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide", "fallback" },
        ["<CR>"] = { "accept", "fallback" },
        ["<C-p>"] = { "select_prev", "snippet_backward", "fallback" },
        ["<C-n>"] = { "select_next", "snippet_forward", "fallback" },
        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },
      },
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = "mono",
      },
      completion = {
        menu = { border = "rounded" },
        documentation = {
          auto_show = true,
          window = { border = "rounded" },
        },
        ghost_text = { enabled = true },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer", "minuet" },
        providers = {
          minuet = {
            name = "minuet",
            module = "minuet.blink",
            score_offset = 100,
          },
        },
      },
      snippets = { preset = "luasnip" },
    },
  },
}
