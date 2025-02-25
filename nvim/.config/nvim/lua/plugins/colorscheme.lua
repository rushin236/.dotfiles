return {
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("tokyonight").setup({
      style = "night",
      on_colors = function(colors)
        colors.bg = "#1a1b26"
        colors.bg_highlight = "#13131a"
        colors.red = "#ff9eaa"
      end
    })
    vim.cmd("colorscheme tokyonight-night")
  end,
}
