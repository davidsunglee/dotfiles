# Theme registry: one canonical slug -> per-tool identifier.
# Sourced by ~/.config/theme/init.zsh. Keep in sync with:
#   fzf palettes  ~/.config/fzf/themes/<slug>.fzf
#   bat themes    ~/.config/bat/themes/<slug>.tmTheme (+ built-ins)

typeset -ga THEME_SLUGS=(
  poimandres nord
  rose-pine rose-pine-moon rose-pine-dawn
  catppuccin-mocha catppuccin-macchiato catppuccin-frappe catppuccin-latte
  tokyonight-night tokyonight-storm tokyonight-moon tokyonight-day
)

# slug -> Ghostty built-in theme name
typeset -gA THEME_GHOSTTY=(
  poimandres           "Poimandres"
  nord                 "Nord"
  rose-pine            "Rose Pine"
  rose-pine-moon       "Rose Pine Moon"
  rose-pine-dawn       "Rose Pine Dawn"
  catppuccin-mocha     "Catppuccin Mocha"
  catppuccin-macchiato "Catppuccin Macchiato"
  catppuccin-frappe    "Catppuccin Frappe"
  catppuccin-latte     "Catppuccin Latte"
  tokyonight-night     "TokyoNight Night"
  tokyonight-storm     "TokyoNight Storm"
  tokyonight-moon      "TokyoNight Moon"
  tokyonight-day       "TokyoNight Day"
)

# slug -> bat theme name (custom tmThemes use the slug; built-ins use their name)
typeset -gA THEME_BAT=(
  poimandres           poimandres
  nord                 "Nord"
  rose-pine            rose-pine
  rose-pine-moon       rose-pine-moon
  rose-pine-dawn       rose-pine-dawn
  catppuccin-mocha     "Catppuccin Mocha"
  catppuccin-macchiato "Catppuccin Macchiato"
  catppuccin-frappe    "Catppuccin Frappe"
  catppuccin-latte     "Catppuccin Latte"
  tokyonight-night     tokyonight-night
  tokyonight-storm     tokyonight-storm
  tokyonight-moon      tokyonight-moon
  tokyonight-day       tokyonight-day
)

# slug -> Neovim colorscheme name (all plugins expose these names directly)
typeset -gA THEME_NVIM=(
  poimandres           poimandres
  nord                 nord
  rose-pine            rose-pine
  rose-pine-moon       rose-pine-moon
  rose-pine-dawn       rose-pine-dawn
  catppuccin-mocha     catppuccin-mocha
  catppuccin-macchiato catppuccin-macchiato
  catppuccin-frappe    catppuccin-frappe
  catppuccin-latte     catppuccin-latte
  tokyonight-night     tokyonight-night
  tokyonight-storm     tokyonight-storm
  tokyonight-moon      tokyonight-moon
  tokyonight-day       tokyonight-day
)

# Which slugs are light backgrounds (everything else is treated as dark)
typeset -gA THEME_ISLIGHT=(
  rose-pine-dawn   1
  catppuccin-latte 1
  tokyonight-day   1
)
