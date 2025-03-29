return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  config = function()
    local wk = require("which-key")
    wk.add({
      { "<leader>f", group = "file" },
      { "<leader>e", group = "explorer" },
      { "<leader>t", group = "tabs" },
      { "<leader>s", group = "surround/split" },
      { "<leader>n", group = "no" },
      { "<leader>g", group = "git" },
      { "<leader>b", group = "buffer" }
    })
  end
}
