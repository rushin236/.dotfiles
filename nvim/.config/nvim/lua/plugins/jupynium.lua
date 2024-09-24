return {
  "kiyoon/jupynium.nvim",
  build = "pip install --user ." or "pip3 install --user .",
  dependecies = {
    "rcarriga/nvim-notify", -- optional
    "stevearc/dressing.nvim", -- optional, UI for :JupyniumKernelSelect
  },
  config = function()
    require("jupynium").setup({
      python_host = "python" or "python3",
    })
  end,
}
