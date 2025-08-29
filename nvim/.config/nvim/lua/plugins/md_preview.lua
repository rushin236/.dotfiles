return {
  "iamcco/markdown-preview.nvim",
  build = "cd app && npm install",
  ft = { "markdown" },
  cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
  config = function()
    vim.g.mkdp_theme = "dark" -- optional, matches GitHub dark style
  end,
}
