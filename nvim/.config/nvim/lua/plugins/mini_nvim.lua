return {
  {
    'echasnovski/mini.surround',
    version = false,
    config = function()
      require("mini.surround").setup({
        mappings = {
          add = 'gsa',            -- add surrounding in normal and visual modes
          delete = 'gsd',         -- delete surrounding
          find = 'gsf',           -- find surrounding (to the right)
          find_left = 'gsf',      -- find surrounding (to the left)
          replace = 'gsr',        -- replace surrounding
          update_n_lines = 'gsn', -- update `n_lines`
        }
      })
    end
  },
  {
    'echasnovski/mini.pairs',
    version = false,
    config = function()
      require("mini.pairs").setup(
        {
          modes = { insert = true, command = false, terminal = false },

          mappings = {
            ['('] = { action = 'open', pair = '()', neigh_pattern = '[^\\].' },
            ['['] = { action = 'open', pair = '[]', neigh_pattern = '[^\\].' },
            ['{'] = { action = 'open', pair = '{}', neigh_pattern = '[^\\].' },

            [')'] = { action = 'close', pair = '()', neigh_pattern = '[^\\].' },
            [']'] = { action = 'close', pair = '[]', neigh_pattern = '[^\\].' },
            ['}'] = { action = 'close', pair = '{}', neigh_pattern = '[^\\].' },

            ['"'] = { action = 'closeopen', pair = '""', neigh_pattern = '[^\\].', register = { cr = false } },
            ["'"] = { action = 'closeopen', pair = "''", neigh_pattern = '[^%a\\].', register = { cr = false } },
            ['`'] = { action = 'closeopen', pair = '``', neigh_pattern = '[^\\].', register = { cr = false } },
          },
        })
    end
  },
  {
    {
      'echasnovski/mini.ai',
      version = false,
      config = function()
        require("mini.ai").setup({
          {
            custom_textobjects = nil,
            mappings = {
              around = 'a',
              inside = 'i',
              around_next = 'an',
              inside_next = 'in',
              around_last = 'al',
              inside_last = 'il',
              goto_left = 'g[',
              goto_right = 'g]',
            },
            n_lines = 50,
            search_method = 'cover_or_next',
            silent = false,
          }
        })
      end
    }
  }
}
