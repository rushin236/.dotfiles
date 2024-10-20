return {
  "akinsho/bufferline.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    {
      "ojroques/nvim-bufdel",
      config = function()
        require("bufdel").setup({
          next = "tabs",
          quit = false, -- Prevent quitting Neovim when the last buffer is deleted
        })
      end,
    },
  },
  keys = {
    { "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle pin" },
    { "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete non-pinned buffers" },
    { "<leader>bo", "<Cmd>BufferLineCloseOthers<CR>", desc = "Delete other buffers" },
    { "<leader>br", "<Cmd>BufferLineCloseRight<CR>", desc = "Delete buffers to the right" },
    { "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>", desc = "Delete buffers to the left" },
    { "<leader>bs", "<Cmd>BufferLinePick<CR>", desc = "Select buffers" },
    { "<leader>br", "<Cmd>e!<CR>", desc = "Reload buffer" },
    { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer" },
    { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
    { "<leader>bd", "<cmd>BufDel<cr>", desc = "Delete Current Bufrn" },
  },
  opts = {
    options = {
      close_command = function(n)
        vim.cmd("BufDel" .. n)
        -- Open NvimTree if it's the last buffer
        if vim.fn.bufnr("$") == 1 then
          vim.cmd("NvimTreeOpen")
        end
      end,
      right_mouse_command = function(n)
        vim.cmd("BufDel" .. n)
        -- Open NvimTree if it's the last buffer
        if vim.fn.bufnr("$") == 1 then
          vim.cmd("NvimTreeOpen")
        end
      end,
      diagnostics = "nvim_lsp",
      always_show_bufferline = true,
      offsets = {
        {
          filetype = "NvimTree",
          text = "Explorer",
          highlight = "Directory",
          text_align = "left",
          separator = true,
        },
      },
    },
  },
}
