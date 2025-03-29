return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  config = function()
    local wk = require("which-key")
    wk.add({
      { "<leader>b",  group = "buffer" },
      { "<leader>c",  group = "code" },
      { "<leader>cr", group = "code restart" },
      { "<leader>e",  group = "explorer" },
      { "<leader>f",  group = "file" },
      { "<leader>g",  group = "git" },
      { "<leader>gh", group = "githunk" },
      { "<leader>n",  group = "no" },
      { "<leader>r",  group = "run/restart" },
      { "<leader>s",  group = "surround/split" },
      { "<leader>t",  group = "tabs" }
    })
  end
}
