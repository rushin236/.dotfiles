return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("lualine").setup({
      options = {
        theme = {
          normal = {
            a = { bg = "#1f2428", fg = "#adbac7", gui = "bold" },
            b = { bg = "#1f2428", fg = "#adbac7" },
            c = { bg = "#1f2428", fg = "#768390" },
          },
          insert = {
            a = { bg = "#1f2428", fg = "#57ab5a", gui = "bold" }, -- Green
            b = { bg = "#1f2428", fg = "#adbac7" },
          },
          visual = {
            a = { bg = "#1f2428", fg = "#b083f0", gui = "bold" }, -- Purple
            b = { bg = "#1f2428", fg = "#adbac7" },
          },
          replace = {
            a = { bg = "#1f2428", fg = "#f47067", gui = "bold" }, -- Red
            b = { bg = "#1f2428", fg = "#adbac7" },
          },
          command = {
            a = { bg = "#1f2428", fg = "#539bf5", gui = "bold" }, -- Blue
            b = { bg = "#1f2428", fg = "#adbac7" },
          },
          inactive = {
            a = { bg = "#1f2428", fg = "#636e7b", gui = "bold" },
            b = { bg = "#1f2428", fg = "#636e7b" },
            c = { bg = "#1f2428", fg = "#636e7b" },
          },
        },
        component_separators = { left = "│", right = "│" },
        section_separators = { left = "", right = "" },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { "filename" },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
      },
    })
  end,
}
