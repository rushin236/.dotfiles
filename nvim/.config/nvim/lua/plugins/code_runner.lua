return {
  "CRAG666/code_runner.nvim",
  cmd = { "RunCode", "RunFile", "RunProject" },
  config = function()
    require("code_runner").setup({
      focus = true,
      filetype = {
        javascript = "node",
        java = {
          "cd $dir &&",
          "javac $fileName &&",
          "java $fileNameWithoutExt",
        },
        c = function(...)
          c_base = {
            "cd $dir &&",
            "gcc $fileName -o",
            "$fileNameWithoutExt",
          }
          local c_exec = {
            "&& $dir/$fileNameWithoutExt",
          }
          vim.ui.input({ prompt = "Add more args:" }, function(input)
            c_base[4] = input
            require("code_runner.commands").run_from_fn(vim.list_extend(c_base, c_exec))
          end)
        end,
        cpp = {
          "cd $dir &&",
          "g++ $fileName",
          "-o $fileNameWithoutExt &&",
          "$dir/$fileNameWithoutExt",
        },
        python = "python -u",
        sh = "bash",
        ruby = "ruby",
        rust = {
          "cd $dir &&",
          "rustc $fileName &&",
          "$dir/$fileNameWithoutExt",
        },
      },
      project_path = vim.fn.expand("~/.config/nvim/project_manager.json"),
    })
  end,
}
