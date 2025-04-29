return {
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("tokyonight").setup({
      style = "night",

      on_colors = function(colors)
        -- GitHub Dark Dimmer color palette
        -- Background colors
        colors.bg = "#1f2428"
        colors.bg_dark = "#1f2428"
        colors.bg_float = "#1f2428"
        colors.bg_highlight = "#2c3135"
        colors.bg_popup = "#1f2428"
        colors.bg_statusline = "#1f2428"
        colors.bg_sidebar = "#1f2428"

        -- Foreground colors
        colors.fg = "#adbac7"
        colors.fg_dark = "#768390"
        colors.fg_float = "#adbac7"
        colors.fg_gutter = "#636e7b"
        colors.fg_sidebar = "#adbac7"

        -- Syntax colors
        -- colors.red = "#f47067"
        -- colors.green = "#57ab5a"
        -- colors.yellow = "#c69026"
        -- colors.blue = "#539bf5"
        -- colors.magenta = "#b083f0"
        -- colors.cyan = "#39c5cf"

        -- UI colors
        colors.comment = "#768390"
        colors.border = "#444c56"
        -- colors.selection = "#316dca"
        -- colors.orange = "#cc6b2c"
        -- colors.pink = "#f47067"

        -- Diagnostic colors
        -- colors.error = "#f47067"
        -- colors.warning = "#c69026"
        -- colors.info = "#539bf5"
        -- colors.hint = "#6cb6ff"
      end,

      on_highlights = function(hl, colors)
        -- Additional highlight overrides
        hl.CursorLine = { bg = "#2c3135" }
        hl.LineNr = { fg = colors.fg_gutter }
        hl.CursorLineNr = { fg = colors.fg }
        hl.Pmenu = { bg = colors.bg_highlight }
        hl.PmenuSel = { bg = "#373e47" }
        hl.NormalFloat = { bg = colors.bg_float }
        hl.FloatBorder = { bg = colors.bg_float, fg = colors.border }
      end,
    })
    vim.cmd.colorscheme("tokyonight")
  end,
}
