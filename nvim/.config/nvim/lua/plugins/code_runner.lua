return {
  "CRAG666/code_runner.nvim",
  config = function()
    require("code_runner").setup({
      filetype = {
        python = "python -u '$dir/$fileName'",
        sh = "bash",
        c = function()
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

              vim.list_extend(c_base, c_exec)
              local cmd_str = table.concat(c_base, " ")
              require("code_runner.commands").run_from_fn(cmd_str)
            end)
          end)
        end,
        cpp = function()
          local cpp_base = {
            "cd $dir &&",
            "gcc $fileName -o",
            "$dir/$fileNameWithoutExt",
          }
          local cpp_exec = {
            "&& $dir/$fileNameWithoutExt",
          }

          vim.ui.input({ prompt = "Add compilation args (e.g., -Wall -g): " }, function(compile_args)
            if compile_args and compile_args ~= "" then
              table.insert(cpp_base, 4, compile_args) -- Append compilation arguments
            end

            vim.ui.input({ prompt = "Add execution args: " }, function(exec_args)
              if exec_args and exec_args ~= "" then
                table.insert(cpp_exec, exec_args) -- Append execution arguments
              end

              vim.list_extend(cpp_base, cpp_exec)
              local cmd_str = table.concat(cpp_base, " ")
              require("code_runner.commands").run_from_fn(cmd_str)
            end)
          end)
        end,
      },
    })

    vim.keymap.set("n", "<leader>crr", ":RunCode<CR>", { noremap = true, silent = false })
    vim.keymap.set("n", "<leader>crf", ":RunFile<CR>", { noremap = true, silent = false })
    vim.keymap.set("n", "<leader>crp", ":RunProject<CR>", { noremap = true, silent = false })
    vim.keymap.set("n", "<leader>crc", ":RunClose<CR>", { noremap = true, silent = false })
  end,
}
