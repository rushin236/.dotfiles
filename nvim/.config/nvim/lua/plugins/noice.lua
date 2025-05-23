return {
  "folke/noice.nvim",
  config = function()
    require("noice").setup({
      cmdline = {
        enabled = true,
        view = "cmdline", -- use bottom command line, not floating
      },
      popupmenu = {
        enabled = true, -- keep completions
        backend = "nui", -- or "cmp" if you're using nvim-cmp for cmdline
      },
      views = {
        cmdline_popup = {
          position = {
            row = 1,
            col = "50%",
          },
          size = {
            width = 60,
            height = "auto",
          },
        },
        popupmenu = {
          relative = "editor",
          position = {
            row = vim.o.lines - 7, -- This positions it just above the cmdline
            col = 1,
          },
          size = {
            width = 60,
            height = 5,
          },
          border = {
            style = "rounded",
            padding = { 0, 1 },
          },
        },
      },
    })
  end,
}
