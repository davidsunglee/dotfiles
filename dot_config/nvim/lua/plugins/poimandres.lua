return {
  {
    "olivercederborg/poimandres.nvim",
    lazy = true,
    opts = {
      bold_vert_split = false, -- use bold vertical separators
      dark_variant = "main", -- currently only "main" exists
      disable_background = false, -- set to true for a transparent background
      disable_float_background = false, -- transparent floating windows
      disable_italics = false, -- turn off all italics
      dim_nc_background = false, -- dim background of non-current windows

      -- Map semantic roles to palette colors. Valid color names (main palette):
      --   yellow, teal1..3, blue1..4, pink1..3, blueGray1..3,
      --   background1..3, text, white, none
      groups = {
        background = "background2",
        panel = "background3",
        border = "background3",
        comment = "blueGray3",
        link = "blue3",
        punctuation = "blue3",

        error = "pink3",
        hint = "blue1",
        info = "blue3",
        warn = "yellow",

        git_add = "teal1",
        git_change = "blue2",
        git_delete = "pink3",
        git_dirty = "blue4",
        git_ignore = "blueGray1",
        git_merge = "blue2",
        git_rename = "teal3",
        git_stage = "blue1",
        git_text = "teal2",

        headings = {
          h1 = "teal2",
          h2 = "yellow",
          h3 = "pink3",
          h4 = "pink2",
          h5 = "blue1",
          h6 = "blue2",
        },
      },

      -- Override any highlight group directly, e.g.
      --   Comment = { fg = "#767C9D", italic = true },
      highlight_groups = {},
    },
  },
}
