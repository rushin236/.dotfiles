return {
  "CRAG666/code_runner.nvim",
  config = function()
    require("code_runner").setup({
      filetype = {
        python = "python -u '$dir/$fileName'",
        sh = "bash",
        c = function(...)
          local c_base = {
            "cd $dir &&",
            "gcc $fileName -o",
            "$dir/$fileNameWithoutExt",
          }
          local c_exec = {
            "&& $dir/$fileNameWithoutExt",
          }
          vim.ui.input({ prompt = "Add more args:" }, function(input)
            c_base[4] = input
            require("code_runner.commands").run_from_fn(vim.list_extend(c_base, c_exec))
          end)
        end,
      },
    })
  end,
}
