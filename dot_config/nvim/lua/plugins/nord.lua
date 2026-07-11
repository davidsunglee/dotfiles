return {
  {
    "gbprod/nord.nvim",
    lazy = true,
    opts = {
      transparent = false, -- enable to skip setting the background color
      terminal_colors = true, -- colors used when opening a `:terminal`
      diff = { mode = "bg" }, -- [bg|fg] how diffs are highlighted
      search = { theme = "vim" }, -- [vim|vscode] search highlight style
      borders = true, -- draw borders between splits/floats
      errors = { mode = "bg" }, -- [bg|fg|none] how errors are highlighted
      -- Any value is a valid attr-list value for `:help nvim_set_hl`
      styles = {
        comments = { italic = true },
        keywords = {},
        functions = {},
        variables = {},
        errors = {},
        -- To customize lualine/bufferline
        bufferline = {
          current = {},
          modified = { italic = true },
        },
      },
      colorblind = {
        enable = false,
        preserve_background = false,
        severity = {
          protan = 0, -- red-blindness    [0..1]
          deutan = 0, -- green-blindness  [0..1]
          tritan = 0, -- blue-blindness   [0..1]
        },
      },
      -- Override palette colors, e.g. colors.polar_night.origin = "#2E3440"
      on_colors = function(colors) end,
      -- Override specific highlights to use other groups or a hex color
      on_highlights = function(highlights, colors) end,
    },
  },
}
