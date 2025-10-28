return {
  "toppair/peek.nvim",
  event = { "VeryLazy" },
  build = "deno task --quiet build:fast",
  config = function()
    local peek = require("peek")

    peek.setup({
      auto_load = false,
      close_on_bdelete = true,
      syntax = true,
      theme = "dark",
      app = "browser", -- or "chromium", "google-chrome"
      update_on_change = true,
    })

    -- Simple toggle function
    local function toggle_peek()
      if peek.is_open() then
        peek.close()
      else
        peek.open()
      end
    end

    -- One keymap to toggle
    vim.keymap.set("n", "<leader>pm", toggle_peek, { desc = "Toggle Peek preview" })
  end,
}
