return {
  {
    "catppuccin/nvim",
    name = "catppuccin", -- required: repo is catppuccin/nvim, so opts map to require("catppuccin")
    lazy = true,
    opts = {
      flavour = "auto", -- latte | frappe | macchiato | mocha | auto (follows background)
      background = { -- flavour used per background when flavour = "auto"
        light = "latte",
        dark = "mocha",
      },
      transparent_background = false, -- disable setting the background color
      float = {
        transparent = false, -- transparent floating windows
        solid = false, -- use a solid border for floats
      },
      term_colors = false, -- set terminal colors (:terminal)
      dim_inactive = {
        enabled = false, -- dim inactive windows
        shade = "dark",
        percentage = 0.15,
      },
      no_italic = false, -- force no italic anywhere
      no_bold = false, -- force no bold anywhere
      no_underline = false, -- force no underline anywhere
      styles = {
        -- Any valid attr-list: "bold", "italic", "underline", ...
        comments = { "italic" },
        conditionals = { "italic" },
        loops = {},
        functions = {},
        keywords = {},
        strings = {},
        variables = {},
        numbers = {},
        booleans = {},
        properties = {},
        types = {},
        operators = {},
      },
      -- Plugin integrations. `default_integrations = true` (the default) turns on a
      -- sensible set already; LazyVim also auto-wires most of these. Add overrides here,
      -- e.g. integrations = { telescope = true, which_key = true }.
      -- Full list: https://github.com/catppuccin/nvim#integrations
      integrations = {},
      color_overrides = {}, -- override palette colors per flavour, e.g. mocha = { base = "#1e1e2e" }
      highlight_overrides = {}, -- override highlight groups per flavour
    },
  },
}
