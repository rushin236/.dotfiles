-- Set root dir if dir is passed
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- Ensure args is always a table
    local args = vim.fn.argv()
    if type(args) == "string" then
      args = { args }
    end

    -- Find the first directory argument
    for _, arg in ipairs(args) do
      if vim.fn.isdirectory(arg) == 1 then
        vim.cmd("silent! cd " .. arg)
        break
      end
    end
  end,
})

local function augroup(name)
  return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
end

-- close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    "PlenaryTestPopup",
    "checkhealth",
    "dbout",
    "gitsigns-blame",
    "grug-far",
    "help",
    "lspinfo",
    "neotest-output",
    "neotest-output-panel",
    "neotest-summary",
    "notify",
    "qf",
    "spectre_panel",
    "startuptime",
    "tsplayground",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set("n", "q", function()
        vim.cmd("close")
        pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
      end, {
        buffer = event.buf,
        silent = true,
        desc = "Quit buffer",
      })
    end)
  end,
})

-- Hightlight yanking
vim.api.nvim_set_hl(0, "YankHighlight", { bg = "#3b3b3d", fg = "#dcdcdc", bold = true })
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.hl.on_yank({ higroup = "YankHighlight", timeout = 250 })
  end,
})
