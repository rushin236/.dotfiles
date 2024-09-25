return {
  "nvim-tree/nvim-tree.lua",
  dependencies = "nvim-tree/nvim-web-devicons",
  config = function()
    local nvimtree = require("nvim-tree")

    -- recommended settings from nvim-tree documentation
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    nvimtree.setup({
      view = {
        width = 35,
        relativenumber = true,
      },
      -- change folder arrow and git icons
      renderer = {
        indent_markers = {
          enable = true,
        },
        icons = {
          glyphs = {
            default = "", -- default file icon
            symlink = "", -- symlink icon
            folder = {
              arrow_closed = "", -- semi-circle for closed folder
              arrow_open = "", -- semi-circle for open folder
              default = "", -- larger-looking closed folder icon
              open = "", -- larger-looking open folder icon
              empty = "", -- larger-looking empty folder
              empty_open = "", -- larger-looking open empty folder
              symlink = "", -- folder symlink icon
            },
            git = {
              unstaged = "", -- unstaged changes
              staged = "", -- staged changes
              unmerged = "", -- unmerged changes
              renamed = "", -- renamed files
              deleted = "", -- deleted files
              untracked = "", -- untracked files
              ignored = "◌", -- ignored files
            },
          },
        },
      },
      -- disable window_picker for explorer to work well with window splits
      actions = {
        open_file = {
          window_picker = {
            enable = false,
          },
        },
      },
      filters = {
        custom = { ".DS_Store" },
      },
      git = {
        ignore = false,
      },
    })

    -- set keymaps
    local keymap = vim
    .keymap                                                                                                             -- for conciseness

    keymap.set("n", "<leader>ee", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })                         -- toggle file explorer
    keymap.set("n", "<leader>ef", "<cmd>NvimTreeFindFileToggle<CR>", { desc = "Toggle file explorer on current file" }) -- toggle file explorer on current file
    keymap.set("n", "<leader>ec", "<cmd>NvimTreeCollapse<CR>", { desc = "Collapse file explorer" })                     -- collapse file explorer
    keymap.set("n", "<leader>er", "<cmd>NvimTreeRefresh<CR>", { desc = "Refresh file explorer" })                       -- refresh file explorer
  end,
}
