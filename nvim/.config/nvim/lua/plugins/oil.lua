return {
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      default_file_explorer = true,
      delete_to_trash = true,
      skip_confirm_for_simple_edits = true,
      view_options = {
        show_hidden = true,
      },
      win_options = {
        signcolumn = "yes:2",
      },
      keymaps = {
        ["g?"] = "actions.show_help",
        ["<CR>"] = "actions.select",
        ["<C-s>"] = "actions.select_split",
        ["<C-v>"] = "actions.select_vsplit",
        ["<C-t>"] = "actions.select_tab",
        ["<C-p>"] = "actions.preview",
        ["<C-c>"] = "actions.close",
        ["g."] = "actions.toggle_hidden",
        -- The new Smart Quit function
        ["q"] = function()
          local win_count = #vim.api.nvim_tabpage_list_wins(0)
          if win_count > 1 then
            vim.cmd("close") -- Closes the physical window if in a split
          else
            require("oil").close() -- Just closes Oil if it's the only window
          end
        end,
      },
    },
    keys = {
      { "-", "<cmd>Oil<CR>", desc = "Open parent directory" },
      { "<leader>fe", "<cmd>Oil<CR>", desc = "File Explorer (Oil)" },
    },
  },
  {
    "refractalize/oil-git-status.nvim",
    dependencies = { "stevearc/oil.nvim" },
    config = true,
  },
}
