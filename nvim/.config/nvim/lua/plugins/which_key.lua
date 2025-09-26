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
        mode = { "n", "v" },
        { "<leader><tab>", group = "tabs" },
        { "<leader>b", group = "buffer" },
        { "<leader>c", group = "code" },
        { "<leader>cr", group = "run" },
        { "<leader>d", group = "debug" },
        { "<leader>f", group = "file/find" },
        { "<leader>g", group = "git" },
        { "<leader>gh", group = "hunks" },
        { "<leader>s", group = "snacks/split" },
        { "<leader>w", group = "windows" },
        { "<leader>x", group = "diagnostics/quickfix" },
        { "[", group = "prev" },
        { "]", group = "next" },
        { "g", group = "goto" },
        { "gs", group = "surround" },
        { "gx", ":!open <cfile><CR>", desc = "Open with system app" },
        { "z", group = "fold" },
      },
      {
        mode = { "o", "x" }, -- operator-pending + visual
        { "ao", group = "around block/conditional/loop" },
        { "io", group = "inside block/conditional/loop" },
        { "af", group = "around function" },
        { "if", group = "inside function" },
        { "ac", group = "around class" },
        { "ic", group = "inside class" },
        { "at", group = "around tag" },
        { "it", group = "inside tag" },
        { "ad", group = "around digit" },
        { "id", group = "inside digit" },
        { "ae", group = "around word (case aware)" },
        { "ie", group = "inside word (case aware)" },
        { "ag", group = "around whole buffer" },
        { "ig", group = "inside whole buffer" },
        { "au", group = "around function call" },
        { "iu", group = "inside function call" },
        { "aU", group = "around function call (simple)" },
        { "iU", group = "inside function call (simple)" },
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
