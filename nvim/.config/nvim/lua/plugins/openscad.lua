return {
  "salkin-mada/openscad.nvim",
  dependencies = {
    "L3MON4D3/LuaSnip", -- Required for code snippets
    "ibhagwan/fzf-lua", -- Required for the fuzzy-finding help picker
  },
  ft = "openscad", -- Lazy-load the plugin only when opening .scad files
  config = function()
    -- Automatically open the OpenSCAD GUI viewer when editing a .scad file
    vim.g.openscad_auto_open = true

    -- Load pre-configured OpenSCAD snippets into LuaSnip
    vim.g.openscad_load_snippets = true

    -- Enable default plugin keymaps
    vim.g.openscad_default_mappings = true

    -- Initialize the plugin
    require("openscad")
  end,
}
