return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  config = function()
    local wk = require("which-key")

    wk.setup({
      preset = "helix",
    })

    wk.add({
      {
        mode = { "n", "x" },
        { "<leader><tab>", group = "tabs" },
        { "<leader>b", group = "buffer" },
        { "<leader>c", group = "code" },
        { "<leader>cr", group = "run" },
        { "<leader>d", group = "debug" },
        { "<leader>f", group = "file/find" },
        { "<leader>g", group = "git" },
        { "<leader>gh", group = "hunks" },
        { "<leader>s", group = "snacks/split" },
        { "<leader>v", group = "Venv" },
        { "<leader>x", group = "diagnostics/quickfix" },
        { "[", group = "prev" },
        { "]", group = "next" },
        { "g", group = "goto" },
        { "gs", group = "surround" },
        { "gx", ":!open <cfile><CR>", desc = "Open with system app" },
        { "z", group = "fold" },
      },
    })

    -- Extra helper mappings
    vim.keymap.set("n", "<leader>?", function()
      wk.show({ global = false })
    end, { desc = "Buffer Keymaps (which-key)" })

    vim.keymap.set("n", "<c-w><space>", function()
      wk.show({ keys = "<c-w>", loop = true })
    end, { desc = "Window Hydra Mode (which-key)" })
  end,
}
