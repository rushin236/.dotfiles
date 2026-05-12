return {
  {
    "milanglacier/minuet-ai.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "saghen/blink.cmp",
    },

    config = function()
      require("minuet").setup({
        -- Keeping FIM because virtual text handles suffixes perfectly
        provider = "openai_fim_compatible",

        n_completions = 1,
        debounce = 80,
        context_window = 4096,
        notify = "warn",

        -- Added the virtual text configuration
        virtualtext = {
          auto_trigger_ft = { "*" },
          keymap = {
            accept = "<A-y>", -- Alt+y to accept the ghost text
            accept_line = "<A-a>", -- Alt+a to accept only the first line
            prev = "<A-[>",
            next = "<A-]>",
            dismiss = "<A-e>",
          },
        },

        provider_options = {
          openai_fim_compatible = {
            api_key = "TERM",
            name = "Ollama",
            -- Using the completions endpoint again for FIM
            end_point = "http://127.0.0.1:11434/v1/completions",
            model = "qwen2.5-coder:7b",
            stream = true,
            optional = {
              max_tokens = 96,
              top_p = 0.9,
              temperature = 0.15,
            },
          },
        },
      })
    end,
  },
  {
    "saghen/blink.cmp",
    version = "*",
    build = "cargo build --release",
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
        -- Removed 'minuet' from here so it doesn't show in the blink popup menu
        default = { "lsp", "path", "snippets", "buffer" },
      },
      snippets = { preset = "luasnip" },
    },
  },
}
