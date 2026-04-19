return {
  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    build = ":UpdateRemotePlugins",

    ft = { "python", "markdown", "quarto" },

    init = function()
      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_auto_open_output = false
      vim.g.molten_wrap_output = true
      vim.g.molten_virt_text_output = true
    end,

    config = function()
      vim.keymap.set("n", "<leader>mi", ":MoltenInit<CR>", { silent = true })
      vim.keymap.set("n", "<leader>mr", ":MoltenEvaluateOperator<CR>", { silent = true })
      vim.keymap.set("n", "<leader>ml", ":MoltenEvaluateLine<CR>", { silent = true })
      vim.keymap.set("v", "<leader>mr", ":<C-u>MoltenEvaluateVisual<CR>gv", { silent = true })
      vim.keymap.set("n", "<leader>mc", ":MoltenReevaluateCell<CR>", { silent = true })
      vim.keymap.set("n", "<leader>mo", ":MoltenShowOutput<CR>", { silent = true })
      vim.keymap.set("n", "<leader>mh", ":MoltenHideOutput<CR>", { silent = true })
      vim.keymap.set("n", "<leader>mk", ":MoltenInterrupt<CR>", { silent = true })
    end,
  },
  {
    "3rd/image.nvim",
    enabled = vim.fn.executable("magick") == 1,
    opts = function()
      return {
        backend = "kitty",
        processor = "magick_cli",
      }
    end,
  },
}
