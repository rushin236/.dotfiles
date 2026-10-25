return {
  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    build = ":UpdateRemotePlugins",

    ft = { "python", "markdown", "quarto", "ipynb", "json" },

    init = function()
      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_auto_open_output = false
      vim.g.molten_wrap_output = true
      vim.g.molten_virt_text_output = true
    end,

    config = function()
      -- Helper to check if Molten is initialized
      local function is_molten_initialized()
        local status_ok, status = pcall(require, "molten.status")
        if status_ok and status.initialized() ~= "" then
          return true
        end
        return false
      end

      -- Wrapper to automatically run actions after kernel initialization
      -- Wrapper to automatically run actions after kernel initialization
      local function ensure_init_and_run(action)
        if is_molten_initialized() then
          action()
        else
          -- Wait for the user to select the kernel, then execute the action automatically
          vim.api.nvim_create_autocmd("User", {
            pattern = "MoltenInitPost",
            once = true,
            callback = function()
              -- Wait 250ms for the ZMQ socket to fully connect before sending code
              vim.defer_fn(action, 250)
            end,
          })
          vim.cmd("MoltenInit")
        end
      end

      -- Asynchronous queue manager to prevent visual mark race conditions
      local function queue_cells_sequentially(cells, idx)
        if idx > #cells then
          return
        end
        eval_lines(cells[idx].start_line, cells[idx].end_line)
        -- Increased delay to 100ms to ensure Molten processes each cell cleanly
        vim.defer_fn(function()
          queue_cells_sequentially(cells, idx + 1)
        end, 100)
      end

      -- Universal helper to invisibly evaluate a precise line range
      local function eval_lines(start_line, end_line)
        if start_line > end_line then
          return
        end

        local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
        while #lines > 0 and lines[#lines]:match("^%s*$") do
          end_line = end_line - 1
          table.remove(lines)
        end
        if start_line > end_line then
          end_line = start_line
        end

        local current_pos = vim.api.nvim_win_get_cursor(0)
        vim.cmd("normal! " .. start_line .. "G0V" .. end_line .. "G\27")
        vim.cmd("MoltenEvaluateVisual")
        vim.api.nvim_win_set_cursor(0, current_pos)
      end

      -- Asynchronous queue manager to prevent visual mark race conditions
      local function queue_cells_sequentially(cells, idx)
        if idx > #cells then
          return
        end
        eval_lines(cells[idx].start_line, cells[idx].end_line)
        vim.defer_fn(function()
          queue_cells_sequentially(cells, idx + 1)
        end, 50)
      end

      local function get_cell_boundaries()
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        local boundaries = {}
        for i, line in ipairs(lines) do
          if line:match("^# %%%%") then
            table.insert(boundaries, i)
          end
        end
        return boundaries
      end

      local function get_current_cell()
        local current_line = vim.fn.line(".")
        local boundaries = get_cell_boundaries()
        if #boundaries == 0 then
          return nil, nil, nil
        end

        local start_line = boundaries[1]
        local end_line = vim.fn.line("$")
        local cell_idx = 1

        for i, bound in ipairs(boundaries) do
          if bound <= current_line then
            start_line = bound
            cell_idx = i
          else
            end_line = bound - 1
            break
          end
        end
        return start_line, end_line, cell_idx
      end

      -- 1. Execution Functions
      local function run_cell(move_to_next)
        ensure_init_and_run(function()
          local start_line, end_line = get_current_cell()
          if not start_line then
            return
          end
          eval_lines(start_line, end_line)

          if move_to_next then
            vim.fn.search("^# %%%%", "W")
          end
        end)
      end

      local function run_all_above()
        ensure_init_and_run(function()
          local _, _, current_idx = get_current_cell()
          if not current_idx then
            return
          end

          local boundaries = get_cell_boundaries()
          local total_lines = vim.fn.line("$")
          local cells_to_run = {}

          for i = 1, current_idx do
            local end_line = boundaries[i + 1] and (boundaries[i + 1] - 1) or total_lines
            table.insert(cells_to_run, { start_line = boundaries[i], end_line = end_line })
          end

          queue_cells_sequentially(cells_to_run, 1)
        end)
      end

      local function run_all_below()
        ensure_init_and_run(function()
          local _, _, current_idx = get_current_cell()
          if not current_idx then
            return
          end

          local boundaries = get_cell_boundaries()
          local total_lines = vim.fn.line("$")
          local cells_to_run = {}
          for i = current_idx, #boundaries do
            local end_line = boundaries[i + 1] and (boundaries[i + 1] - 1) or total_lines
            table.insert(cells_to_run, { start_line = boundaries[i], end_line = end_line })
          end
          queue_cells_sequentially(cells_to_run, 1)
        end)
      end

      local function run_all()
        ensure_init_and_run(function()
          local boundaries = get_cell_boundaries()
          local total_lines = vim.fn.line("$")
          local cells_to_run = {}
          for i, start_line in ipairs(boundaries) do
            local end_line = boundaries[i + 1] and (boundaries[i + 1] - 1) or total_lines
            table.insert(cells_to_run, { start_line = start_line, end_line = end_line })
          end
          queue_cells_sequentially(cells_to_run, 1)
        end)
      end

      -- 2. Spaced Cell Management (Smart Gap Detection)
      local function insert_cell(is_markdown, is_above)
        local marker = is_markdown and "# %% [markdown]" or "# %%"

        if vim.api.nvim_buf_line_count(0) == 1 and vim.api.nvim_get_current_line() == "" then
          vim.api.nvim_buf_set_lines(0, 0, -1, false, { marker, "", "" })
          vim.api.nvim_win_set_cursor(0, { 2, 0 })
          return
        end

        if is_above then
          local start_line = vim.fn.search("^# %%", "bcW")
          if start_line == 0 then
            start_line = 1
          end

          vim.api.nvim_buf_set_lines(0, start_line - 1, start_line - 1, false, { marker, "", "" })
          vim.api.nvim_win_set_cursor(0, { start_line + 1, 0 })
        else
          vim.cmd("normal! $")
          local next_cell = vim.fn.search("^# %%", "nW")

          if next_cell == 0 then
            local last_line = vim.fn.line("$")
            local last_line_content =
              vim.api.nvim_buf_get_lines(0, last_line - 1, last_line, false)[1]

            if last_line_content == "" then
              -- Replace the existing empty line to prevent double gaps
              vim.api.nvim_buf_set_lines(0, last_line - 1, last_line, false, { "", marker, "", "" })
              vim.api.nvim_win_set_cursor(0, { last_line + 2, 0 })
            else
              vim.api.nvim_buf_set_lines(0, last_line, last_line, false, { "", marker, "", "" })
              vim.api.nvim_win_set_cursor(0, { last_line + 3, 0 })
            end
          else
            local line_before =
              vim.api.nvim_buf_get_lines(0, next_cell - 2, next_cell - 1, false)[1]

            if line_before == "" then
              -- Replace the existing empty line to prevent double gaps
              vim.api.nvim_buf_set_lines(
                0,
                next_cell - 2,
                next_cell - 1,
                false,
                { "", marker, "", "" }
              )
              vim.api.nvim_win_set_cursor(0, { next_cell + 1, 0 })
            else
              -- Force the full structure to match the clean spacing of "insert above"
              vim.api.nvim_buf_set_lines(
                0,
                next_cell - 1,
                next_cell - 1,
                false,
                { "", marker, "", "" }
              )
              vim.api.nvim_win_set_cursor(0, { next_cell + 2, 0 })
            end
          end
        end
      end

      -- 3. Execution Keymaps
      vim.keymap.set("n", "<leader>mi", ":MoltenInit<CR>", { silent = true, desc = "Init Molten" })

      vim.keymap.set("n", "<leader>mrc", function()
        run_cell(false)
      end, { silent = true, desc = "Run Cell" })
      vim.keymap.set(
        "n",
        "<leader>mra",
        run_all_above,
        { silent = true, desc = "Run All Above (Inclusive)" }
      )
      vim.keymap.set(
        "n",
        "<leader>mrb",
        run_all_below,
        { silent = true, desc = "Run All Below (Inclusive)" }
      )
      vim.keymap.set("n", "<leader>mrA", run_all, { silent = true, desc = "Run All Cells" })

      vim.keymap.set("n", "<S-CR>", function()
        run_cell(true)
      end, { silent = true, desc = "Run Cell & Next" })

      -- 4. Navigation
      vim.keymap.set("n", "<leader>mn", function()
        vim.cmd("silent! /^# %%")
        vim.cmd("nohlsearch")
      end, { silent = true, desc = "Next Cell" })

      vim.keymap.set("n", "<leader>mp", function()
        vim.cmd("silent! ?^# %%")
        vim.cmd("nohlsearch")
      end, { silent = true, desc = "Prev Cell" })

      -- 5. Cell Management Keymaps
      vim.keymap.set("n", "<leader>mcb", function()
        insert_cell(false, false)
      end, { desc = "Code Cell Below" })
      vim.keymap.set("n", "<leader>mca", function()
        insert_cell(false, true)
      end, { desc = "Code Cell Above" })
      vim.keymap.set("n", "<leader>mmb", function()
        insert_cell(true, false)
      end, { desc = "Markdown Cell Below" })
      vim.keymap.set("n", "<leader>mma", function()
        insert_cell(true, true)
      end, { desc = "Markdown Cell Above" })

      -- 6. Robust Delete Keymap
      vim.keymap.set("n", "<leader>md", function()
        local current_cell = vim.fn.search("^# %%", "bcW")
        if current_cell == 0 then
          vim.api.nvim_buf_set_lines(0, 0, -1, false, { "" })
          return
        end
        vim.cmd("normal! V")
        local next_cell = vim.fn.search("^# %%", "nW")
        if next_cell ~= 0 then
          vim.cmd("normal! " .. (next_cell - 1) .. "G")
        else
          vim.cmd("normal! G")
        end
        vim.cmd("normal! d")
      end, { silent = true, desc = "Delete Cell" })

      -- 7. Output Management
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
