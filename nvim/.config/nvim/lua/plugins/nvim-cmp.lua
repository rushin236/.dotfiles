return {
  "hrsh7th/nvim-cmp",
  event = { "InsertEnter", "CmdlineEnter" },
  branch = "main",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    {
      "L3MON4D3/LuaSnip",
      version = "v2.*",
      build = "make install_jsregexp",
      dependencies = {
        "rafamadriz/friendly-snippets",
      },
    },
    "saadparwaiz1/cmp_luasnip",
  },
  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")

    require("luasnip.loaders.from_vscode").lazy_load()
    luasnip.config.set_config({
      history = true,
      updateevents = "TextChanged,TextChangedI",
    })

    -- Do NOT auto-load large snippet collections
    -- Add your own snippets manually if needed

    -- vim.o.completeopt = "menu,menuone,noselect"

    cmp.setup({
      ------------------------------------------------------------------
      -- Core behavior (blink-like)
      ------------------------------------------------------------------
      preselect = cmp.PreselectMode.None,

      completion = {
        -- autocomplete = false, -- manual only
        autocomplete = { "InsertEnter", "TextChanged" },
        completeopt = "menu,menuone,noselect",
        -- completeopt = "menu,menuone",
      },

      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },

      ------------------------------------------------------------------
      -- Minimal sources
      ------------------------------------------------------------------
      sources = {
        { name = "luasnip" },
        { name = "nvim_lsp" },
        { name = "buffer" },
        { name = "path" },
      },

      ------------------------------------------------------------------
      -- Windows (completion only)
      ------------------------------------------------------------------
      window = {
        completion = cmp.config.window.bordered("rounded"),
        documentation = nil, -- disable docs window (performance)
      },

      ------------------------------------------------------------------
      -- Keymaps (single navigation model)
      ------------------------------------------------------------------
      mapping = {
        ["<C-Space>"] = cmp.mapping.complete(),

        ["<C-n>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.jumpable(1) then
            luasnip.jump(1)
          else
            fallback()
          end
        end, { "i", "s" }),

        ["<C-p>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),

        ["<CR>"] = cmp.mapping.confirm({ select = false }),
        ["<C-e>"] = cmp.mapping.abort(),

        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
      },
    })

    ------------------------------------------------------------------
    -- Snippet navigation only (no completion logic)
    ------------------------------------------------------------------
    -- vim.keymap.set({ "i", "s" }, "<Tab>", function()
    --   if luasnip.expand_or_jumpable() then
    --     luasnip.expand_or_jump()
    --   else
    --     return "<Tab>"
    --   end
    -- end, { expr = true, silent = true })
    --
    -- vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
    --   if luasnip.jumpable(-1) then
    --     luasnip.jump(-1)
    --   else
    --     return "<S-Tab>"
    --   end
    -- end, { expr = true, silent = true })

    -- Search (`/`, `?`)
    cmp.setup.cmdline({ "/", "?" }, {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = "buffer" },
      },
    })

    -- Command-line (`:`)
    cmp.setup.cmdline(":", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = "path" },
        { name = "cmdline" },
      },
    })
  end,
}
