return {
  "neovim/nvim-lspconfig",
  ---@class PluginLspOpts
  opts = {
    ---@type lspconfig.options
    servers = {
      pyright = {},
      bashls = {
        filetypes = { "sh", "zsh" },
      },
    },
  },
}
