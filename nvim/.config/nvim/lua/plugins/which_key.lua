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
        { "<leader>s", group = "split" },
        { "<leader>v", group = "venv" },
        { "<leader>x", group = "diagnostics/quickfix" },
        { "[", group = "prev" },
        { "]", group = "next" },
        { "g", group = "goto" },
        { "gs", group = "surround" },
        { "gx", ":!open <cfile><CR>", desc = "Open with system app" },
        { "z", group = "fold" },
      },
      {
        mode = { "o", "x" },
        { "ao", desc = "around block/conditional/loop" },
        { "io", desc = "inside block/conditional/loop" },
        { "af", desc = "around function" },
        { "if", desc = "inside function" },
        { "ac", desc = "around class" },
        { "ic", desc = "inside class" },
        { "at", desc = "around tag" },
        { "it", desc = "inside tag" },
        { "ad", desc = "around digit" },
        { "id", desc = "inside digit" },
        { "ae", desc = "around word (case aware)" },
        { "ie", desc = "inside word (case aware)" },
        { "ag", desc = "around whole buffer" },
        { "ig", desc = "inside whole buffer" },
        { "au", desc = "around function call" },
        { "iu", desc = "inside function call" },
        { "aU", desc = "around function call (simple)" },
        { "iU", desc = "inside function call (simple)" },
      },
      {
        mode = { "n", "x", "o" },
        { "]f", desc = "Next function start" },
        { "]c", desc = "Next class start" },
        { "]a", desc = "Next parameter start" },
        { "]F", desc = "Next function end" },
        { "]C", desc = "Next class end" },
        { "]A", desc = "Next parameter end" },
        { "[f", desc = "Previous function start" },
        { "[c", desc = "Previous class start" },
        { "[a", desc = "Previous parameter start" },
        { "[F", desc = "Previous function end" },
        { "[C", desc = "Previous class end" },
        { "[A", desc = "Previous parameter end" },
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
