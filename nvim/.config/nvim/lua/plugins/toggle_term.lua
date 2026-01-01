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
      size = 12,
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

    function _G.set_terminal_keymaps()
      local opts = { buffer = 0 }
      vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
      vim.keymap.set("t", "jk", [[<C-\><C-n>]], opts)
      vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
      vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
      vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
      vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
      vim.keymap.set("t", "<C-w>", [[<C-\><C-n><C-w>]], opts)
    end

    -- if you only want these mappings for toggle term use term://*toggleterm#* instead
    vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")
  end,
}
