return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- optional
    "MunifTanjim/nui.nvim",
  },
  config = function()
    require("neo-tree").setup({
      popup_border_style = "rounded",
      enable_git_status = true,
      enable_diagnostics = false,
      default_component_configs = {
        indent = {
          indent_size = 2,
          padding = 0,
          with_markers = true,
          indent_marker = "│",
          last_indent_marker = "└",
          highlight = "NeoTreeIndent",
          with_expanders = true,
          expander_collapsed = "",
          expander_expanded = "",
        },
        icon = {
          folder_closed = "",
          folder_open = "",
          folder_empty = "",
          folder_empty_open = "",
          default = "",
          highlight = "NeoTreeFileIcon",
        },
        name = {
          highlight = "NeoTreeFileName",
        },
        git_status = {
          highlight = "NeoTreeGitStatus",
        },
      },
      filesystem = {
        bind_to_cwd = true,
        follow_current_file = {
          enabled = true,
        },
        use_libuv_file_watcher = true,
      },
      window = {
        position = "left",
        width = 30,
        mappings = {
          ["<space>"] = "none",
        },
      },
    })

    -- Highlight overrides
    local set_hl = vim.api.nvim_set_hl
    set_hl(0, "NeoTreeNormal", { fg = "#d3dbe3", bg = "#181b1e" })
    set_hl(0, "NeoTreeNormalNC", { fg = "#d3dbe3", bg = "#181b1e" })
    set_hl(0, "NeoTreeEndOfBuffer", { fg = "#181b1e", bg = "#181b1e" })
    set_hl(0, "NeoTreeDirectoryName", { fg = "#d3dbe3" })
    set_hl(0, "NeoTreeDirectoryIcon", { fg = "#768390" })
    set_hl(0, "NeoTreeFileName", { fg = "#d3dbe3" })
    set_hl(0, "NeoTreeFileNameOpened", { fg = "#768390", italic = true })
    set_hl(0, "NeoTreeIndentMarker", { fg = "#373e47" })
    set_hl(0, "NeoTreeGitAdded", { fg = "#768390" })
    set_hl(0, "NeoTreeGitModified", { fg = "#768390" })
    set_hl(0, "NeoTreeGitDeleted", { fg = "#768390" })
    set_hl(0, "NeoTreeGitConflict", { fg = "#768390" })
    set_hl(0, "NeoTreeRootName", { fg = "#d3dbe3", bold = true })
    set_hl(0, "NeoTreeTitleBar", { fg = "#181b1e", bg = "#d3dbe3" })

    -- Toggle Neo-tree in the current working directory
    vim.keymap.set("n", "<leader>fe", "<cmd>Neotree toggle<cr>", { desc = "Neo-tree (cwd)" })

    -- Reveal the current buffer’s file in Neo-tree
    vim.keymap.set("n", "<leader>fE", function()
      -- Open Neo-tree anchored at the file’s directory, focusing that file
      require("neo-tree.command").execute({
        action = "focus", -- or "show", depending on preference
        source = "filesystem", -- can also be "buffers" or "git_status"
        position = "left", -- left, right, float etc
        reveal = true, -- ensures it reveals the current file
      })
    end, { desc = "Neo-tree (reveal current file)" })
  end,
}
