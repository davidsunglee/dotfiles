return {
  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = {
      style = "moon", -- storm | moon | night (dark) — pick via colorscheme.lua too
      light_style = "day", -- style used when background is light
      transparent = false, -- disable setting the background color
      terminal_colors = true, -- colors used when opening a `:terminal`
      styles = {
        -- Any valid attr-list value for `:help nvim_set_hl`
        comments = { italic = true },
        keywords = { italic = true },
        functions = {},
        variables = {},
        -- Background styles: "dark" | "transparent" | "normal"
        sidebars = "dark", -- style for sidebars
        floats = "dark", -- style for floating windows
      },
      day_brightness = 0.3, -- brightness of the Day style colors [0..1], dull → vibrant
      dim_inactive = false, -- dim inactive windows
      lualine_bold = false, -- bold section headers in the lualine theme
      cache = true, -- cache the compiled theme for better performance
      -- Override palette colors, e.g. colors.hint = colors.orange
      on_colors = function(colors) end,
      -- Override specific highlights to use other groups or a hex color
      on_highlights = function(highlights, colors) end,
    },
  },
}
