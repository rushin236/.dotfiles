return {
  "nvim-mini/mini.indentscope",
  version = "*",
  event = "BufReadPre",
  config = function()
    -- Vertical scope line (thicker)
    vim.api.nvim_set_hl(0, "MiniIndentscopeSymbol", {
      fg = "#444c56",
    })

    -- Start of current indent scope (underline)
    vim.api.nvim_set_hl(0, "MiniIndentscopePrefix", {
      underline = true,
      fg = "#444c56",
    })

    require("mini.indentscope").gen_animation.none()

    require("mini.indentscope").setup({
      symbol = "┃", -- thicker line
      draw = {
        delay = 0, -- no animation
      },
      options = {
        try_as_border = true,
      },
    })
  end,
}
