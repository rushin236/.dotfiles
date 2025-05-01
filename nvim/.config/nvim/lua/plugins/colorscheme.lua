return {
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("tokyonight").setup({
      style = "night", -- Options: 'storm', 'moon', 'night', 'day'
      light_style = "day", -- Style to use when background is light
      transparent = false, -- Enable transparent background
      terminal_colors = true, -- Use colors for terminals
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
        functions = {},
        variables = {},
        sidebars = "dark", -- 'dark', 'transparent', or 'normal'
        floats = "dark", -- same as above
      },
      day_brightness = 0.3, -- Used when `style` is 'day'
      dim_inactive = false, -- Dim inactive windows
      lualine_bold = false, -- Use bold for `lualine` section headers
      cache = true, -- Enable caching (improves performance)
      plugins = { -- Override specific plugin highlight groups
        -- example: enable = true, or customize plugin-specific colors here
      },

      on_colors = function(colors)
        -- GitHub Dark Dimmer color palette
        -- Background colors
        colors.bg = "#181b1e"
        colors.bg_dark = "#181b1e"
        colors.bg_float = "#181b1e"
        colors.bg_highlight = "#2c3135"
        colors.bg_popup = "#181b1e"
        colors.bg_statusline = "#181b1e"
        colors.bg_sidebar = "#181b1e"

        -- Foreground colors
        colors.fg = "#adbac7"
        colors.fg_dark = "#768390"
        colors.fg_float = "#adbac7"
        colors.fg_gutter = "#636e7b"
        colors.fg_sidebar = "#adbac7"

        -- UI colors
        colors.comment = "#768390"
        colors.border = "#444c56"
        colors.bg_visual = "#444c56"
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
