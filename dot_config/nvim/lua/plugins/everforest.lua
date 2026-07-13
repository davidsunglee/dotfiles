return {
  {
    "sainnhe/everforest",
    lazy = true,
    -- vimscript plugin (no setup()): colorscheme "everforest"; light/dark follows
    -- vim.o.background, hard/medium/soft via g:everforest_background.
    init = function()
      vim.g.everforest_background = "medium"
      vim.g.everforest_better_performance = 1
    end,
  },
}
