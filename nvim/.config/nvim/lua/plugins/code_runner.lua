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

          vim.ui.input({ prompt = "Add compilation args (e.g., -Wall -g): " }, function(compile_args)
            if compile_args and compile_args ~= "" then
              table.insert(c_base, 4, compile_args) -- Append compilation arguments
            end

            vim.ui.input({ prompt = "Add execution args: " }, function(exec_args)
              if exec_args and exec_args ~= "" then
                table.insert(c_exec, exec_args) -- Append execution arguments
              end

              require("code_runner.commands").run_from_fn(vim.list_extend(c_base, c_exec))
            end)
          end)
        end,
      },
    })
  end,
}
