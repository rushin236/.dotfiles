return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("lualine").setup({
      options = {
        theme = {
          normal = {
            a = { bg = "#d3dbe3", fg = "#181b1e", gui = "bold" },
            b = { bg = "#2d333b", fg = "#d3dbe3" },
            c = { bg = "#181b1e", fg = "#768390" },
          },
          insert = {
            a = { bg = "#d3dbe3", fg = "#181b1e", gui = "bold" },
            b = { bg = "#2d333b", fg = "#d3dbe3" },
          },
          visual = {
            a = { bg = "#d3dbe3", fg = "#181b1e", gui = "bold" },
            b = { bg = "#2d333b", fg = "#d3dbe3" },
          },
          replace = {
            a = { bg = "#d3dbe3", fg = "#181b1e", gui = "bold" },
            b = { bg = "#2d333b", fg = "#d3dbe3" },
          },
          command = {
            a = { bg = "#d3dbe3", fg = "#181b1e", gui = "bold" },
            b = { bg = "#2d333b", fg = "#d3dbe3" },
          },
          inactive = {
            a = { bg = "#181b1e", fg = "#768390", gui = "bold" },
            b = { bg = "#181b1e", fg = "#768390" },
            c = { bg = "#181b1e", fg = "#768390" },
          },
        },
        component_separators = { left = "│", right = "│" },
        section_separators = { left = "", right = "" },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff" },
        lualine_c = { "filename" },
        lualine_x = { "filetype" },
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
