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
        -- Disable conflicting defaults
        ["<C-h>"] = false,
        ["<C-l>"] = false,
        ["<C-s>"] = false,
        ["<C-v>"] = false,
        ["<C-p>"] = false,
        ["<C-c>"] = false,
        ["<C-t>"] = false,
        ["gs"] = false,
        ["gx"] = false,
        ["g."] = false,
        ["g?"] = false,
        ["g\\"] = false,
        ["g~"] = false,
        ["`"] = false,
        ["-"] = false,
        ["_"] = false,

        -- Your keymaps
        ["<leader>o?"] = "actions.show_help",
        ["<CR>"] = "actions.select",
        ["<leader>o-"] = "actions.select_split",
        ["<leader>o\\"] = "actions.select_vsplit",
        ["<leader>ot"] = "actions.select_tab",
        ["<leader>op"] = "actions.preview",
        ["<leader>oc"] = "actions.close",
        ["<leader>oh"] = "actions.toggle_hidden",
        ["<leader>or"] = "actions.refresh",
        ["<leader>os"] = "actions.change_sort",
        ["<leader>ox"] = "actions.open_external",
        ["<leader>oo"] = "actions.parent",
        ["<leader>o_"] = "actions.open_cwd",
        ["<leader>o`"] = "actions.cd",
        ["<leader>o~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },
        ["<leader>ob"] = { "actions.toggle_trash", mode = "n" },

        -- Smart quit
        ["q"] = function()
          local win_count = #vim.api.nvim_tabpage_list_wins(0)
          if win_count > 1 then
            vim.cmd("close")
          else
            require("oil").close()
          end
        end,
      },
    },
    keys = {
      { "-", "<cmd>Oil<CR>", desc = "File Explorer (Oil)" },
      { "<leader>fe", "<cmd>Oil<CR>", desc = "File Explorer (Oil)" },
    },
  },
  {
    "refractalize/oil-git-status.nvim",
    dependencies = { "stevearc/oil.nvim" },
    config = true,
  },
}
