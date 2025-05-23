return {
  "MagicDuck/grug-far.nvim",
  config = function()
    require("grug-far").setup({
      minSearchChars = 1,
    })
  end,
}
