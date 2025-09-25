return {
  "akinsho/toggleterm.nvim",
  version = "*",
  event = "VeryLazy",
  config = function()
    local toggleterm = require("toggleterm")

    -- Detect the OS
    local os_name = vim.loop.os_uname().sysname
    local shell = ""

    if os_name == "Windows_NT" then
      shell = "pwsh.exe" -- Use PowerShell on Windows
    elseif os_name == "Linux" then
      -- Detect if running in WSL
      if vim.fn.has("wsl") == 1 then
        shell = vim.o.shell -- Use bash for WSL
      else
        shell = vim.o.shell -- Use bash for Linux
      end
    else
      shell = vim.o.shell -- Default to bash for other systems
    end

    toggleterm.setup({
      shell = shell,
      size = 10,
      -- open_mapping = [[<C-\>]],
      hide_numbers = true,
      shade_filetypes = {},
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = true,
      insert_mappings = true,
      persist_size = true,
      direction = "horizontal",
      close_on_exit = true,
      float_opts = {
        border = "curved",
        winblend = 0,
        highlights = {
          border = "Normal",
          background = "Normal",
        },
      },
    })

    local map = vim.keymap.set

    map(
      { "n" },
      "<C-\\>",
      '<Cmd>execute v:count . "ToggleTerm"<CR>',
      { desc = "Toggle Terminal", noremap = true }
    )
    map("t", "<C-\\>", "<Cmd>ToggleTerm<CR>", { desc = "Toggle Terminal", noremap = true })
    map("i", "<C-\\>", "<Esc><Cmd>ToggleTerm<CR>", { desc = "Toggle Terminal", noremap = true })
  end,
}
