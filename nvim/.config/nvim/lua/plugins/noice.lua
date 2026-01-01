return {
  "folke/noice.nvim",
  config = function()
    require("noice").setup({
      cmdline = {
        enabled = true,
        view = "cmdline", -- use bottom command line, not floating
        format = {
          -- conceal: (default=true) This will hide the text in the cmdline that matches the pattern.
          -- view: (default is cmdline view)
          -- opts: any options passed to the view
          -- icon_hl_group: optional hl_group for the icon
          -- title: set to anything or empty string to hide
          cmdline = { pattern = "^:", icon = " :", lang = "vim" },
          -- search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
          -- search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
          -- filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
          -- lua = { pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" }, icon = "", lang = "lua" },
          -- help = { pattern = "^:%s*he?l?p?%s+", icon = "" },
          -- input = { view = "cmdline_input", icon = "󰥻 " }, -- Used by input()
          -- lua = false, -- to disable a format, set to `false`
        },
      },
      lsp = {
        override = {
          -- override the default lsp markdown formatter with Noice
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          -- override the lsp markdown formatter with Noice
          ["vim.lsp.util.stylize_markdown"] = true,
          -- override cmp documentation with Noice (needs the other options to work)
          ["cmp.entry.get_documentation"] = true,
        },
      },
      popupmenu = {
        enabled = true, -- keep completions
        backend = "nui", -- or "cmp" if you're using nvim-cmp for cmdline
      },
      views = {
        hover = {
          relative = "cursor",
          border = {
            style = "rounded",
          },
          win_options = {
            winhighlight = {
              Normal = "NormalFloat",
              FloatBorder = "FloatBorder",
            },
          },
        },
        cmdline_popup = {
          border = {
            style = "rounded",
          },
          position = {
            row = 1,
            col = "50%",
          },
          size = {
            width = 60,
            height = "auto",
          },
        },
        popupmenu = {
          relative = "editor",
          position = {
            row = vim.o.lines - 7, -- This positions it just above the cmdline
            col = 1,
          },
          size = {
            width = 60,
            height = 5,
          },
          border = {
            style = "rounded",
            padding = { 0, 1 },
          },
          win_options = {
            winhighlight = {
              Normal = "NormalFloat",
              FloatBorder = "FloatBorder",
            },
          },
        },
      },
    })
  end,
}
