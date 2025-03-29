return {
  "stevearc/dressing.nvim",
  event = "VeryLazy",
  config = function()
    require("dressing").setup({
      input = {
        enabled = true,
        default_prompt = "❯ ",
        border = "rounded",       -- Rounded border for better UI
        title_pos = "center",
        relative = "editor",      -- Ensures it's aligned with the editor
        prefer_width = 40,        -- Adjust width for better alignment
        min_width = 20,           -- Prevents being too small
        max_width = { 140, 0.9 }, -- Uses up to 90% of editor width
        win_options = {
          winblend = 10,          -- Semi-transparent background
          wrap = false,           -- Prevents text wrapping
          list = false,           -- Removes list mode
        },
      },
    })
  end,
}
