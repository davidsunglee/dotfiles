return {
  {
    "LazyVim/LazyVim",
    opts = {
      -- The active colorscheme is chosen dynamically by the unified theme
      -- controller (~/.config/theme/state + macOS light/dark appearance).
      -- See lua/config/theme.lua. Running instances follow OS flips and
      -- `theme <slot> <slug>` changes automatically.
      colorscheme = function()
        require("config.theme").apply()
      end,
    },
  },
}
