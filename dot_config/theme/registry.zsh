# Theme registry: one canonical slug -> per-tool identifier.
# Sourced by ~/.config/theme/init.zsh. Keep in sync with:
#   fzf palettes  ~/.config/fzf/themes/<slug>.fzf
#   bat themes    ~/.config/bat/themes/<slug>.tmTheme (+ built-ins)
#   herdr / hunk  the THEME_HERDR / THEME_HUNK maps below (edit freely to tune)
#   vivid         THEME_VIVID below (LS_COLORS -> eza/ls/fd/fzf previews)
#   btop          THEME_BTOP below (+ .theme files in ~/.config/btop/themes/)
#   zed           THEME_ZED below (+ auto_install_extensions in settings.json)
#   opencode      THEME_OPENCODE below (+ custom JSONs in ~/.config/opencode/themes/)

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

# slug -> herdr built-in theme (`~/.config/herdr/config.toml` [theme] block).
# herdr's built-ins are COARSE — this is the escape hatch: map to an exact
# built-in when one exists, to "terminal" (inherit Ghostty's live ANSI palette)
# when none fits, and tune the rest by trial and error over time.
# herdr built-ins: terminal, nord, rose-pine, rose-pine-dawn, catppuccin,
#   catppuccin-latte, tokyo-night, tokyo-night-day, dracula, gruvbox,
#   gruvbox-light, one-dark, one-light, solarized, solarized-light,
#   kanagawa, kanagawa-lotus, vesper. (No poimandres; catppuccin & tokyonight
#   each collapse to a single flavor; no rose-pine-moon.)
typeset -gA THEME_HERDR=(
  poimandres           terminal          # no herdr poimandres -> Ghostty ANSI is the best match; tune
  nord                 nord              # exact
  rose-pine            rose-pine         # exact
  rose-pine-moon       terminal          # -> terminal
  rose-pine-dawn       rose-pine-dawn    # exact
  catppuccin-mocha     catppuccin        # exact
  catppuccin-macchiato terminal          # -> terminal
  catppuccin-frappe    terminal          # -> terminal
  catppuccin-latte     catppuccin-latte  # exact
  tokyonight-night     tokyo-night       # exact
  tokyonight-storm     terminal          # -> terminal
  tokyonight-moon      terminal          # -> terminal
  tokyonight-day       tokyo-night-day   # exact
)

# slug -> hunk built-in theme (`~/.config/hunk/config.toml` theme key).
# hunk (v0.17+) ships EXACT built-ins for almost every slug, so this is nearly
# 1:1. Replaces the old `theme = "auto"` (which OSC-queried the terminal bg and,
# when unanswered, fell back to github-dark-default -- the "stuck default" bug).
# hunk built-ins incl.: poimandres, nord, rose-pine{,-moon,-dawn},
#   catppuccin-{mocha,macchiato,frappe,latte}, tokyo-night, dracula{,-soft},
#   gruvbox-*, solarized-{dark,light}, one-dark-pro, one-light, monokai, ayu-*,
#   github-{dark,light}-* , everforest-*, night-owl{,-light}, vitesse-*, etc.
#   (No tokyo-night light/day variant.) Run `t` inside hunk to preview others.
typeset -gA THEME_HUNK=(
  poimandres           poimandres            # exact
  nord                 nord                  # exact
  rose-pine            rose-pine             # exact
  rose-pine-moon       rose-pine-moon        # exact
  rose-pine-dawn       rose-pine-dawn        # exact
  catppuccin-mocha     catppuccin-mocha      # exact
  catppuccin-macchiato catppuccin-macchiato  # exact
  catppuccin-frappe    catppuccin-frappe     # exact
  catppuccin-latte     catppuccin-latte      # exact
  tokyonight-night     tokyo-night           # hunk has a single tokyo-night
  tokyonight-storm     tokyo-night           # collapses to tokyo-night
  tokyonight-moon      tokyo-night           # collapses to tokyo-night
  tokyonight-day       github-light-default  # no tokyo light in hunk; tune (one-light/solarized-light)
)

# slug -> vivid theme (generates LS_COLORS; drives eza, ls, fd, and the fzf file
# previews). vivid 0.11 ships exact built-ins for 12/13 slugs; only poimandres
# has no vivid theme, so it borrows tokyonight-night's palette (tune candidate).
typeset -gA THEME_VIVID=(
  poimandres           tokyonight-night      # no vivid poimandres -> nearest; tune
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

# slug -> btop theme name (the color_theme value = a .theme file stem in
# ~/.config/btop/themes/, or a btop built-in). Catppuccin/Rose Pine/TokyoNight
# .theme files were fetched from their official repos; nord + tokyo-night ship
# with btop. poimandres has no btop theme anywhere -> nearest built-in tokyo-night.
typeset -gA THEME_BTOP=(
  poimandres           tokyo-night           # built-in nearest; no poimandres .theme exists
  nord                 nord                  # btop built-in
  rose-pine            rose-pine
  rose-pine-moon       rose-pine-moon
  rose-pine-dawn       rose-pine-dawn
  catppuccin-mocha     catppuccin_mocha
  catppuccin-macchiato catppuccin_macchiato
  catppuccin-frappe    catppuccin_frappe
  catppuccin-latte     catppuccin_latte
  tokyonight-night     tokyonight_night
  tokyonight-storm     tokyonight_storm
  tokyonight-moon      tokyonight_moon
  tokyonight-day       tokyonight_day
)

# slug -> Zed theme display name (EXACT strings from each theme extension -- the
# accents matter, or Zed silently keeps the previous theme). Extensions install
# via the auto_install_extensions block in settings.json: catppuccin,
# rose-pine-theme, tokyo-night, nord, poimandres. Zed hot-reloads settings.json
# and flips light/dark natively when theme.mode = "system".
typeset -gA THEME_ZED=(
  poimandres           "poimandres"          # mshaugh/poimandres.zed (lowercase name)
  nord                 "Nord"
  rose-pine            "Rosé Pine"
  rose-pine-moon       "Rosé Pine Moon"
  rose-pine-dawn       "Rosé Pine Dawn"
  catppuccin-mocha     "Catppuccin Mocha"
  catppuccin-macchiato "Catppuccin Macchiato"
  catppuccin-frappe    "Catppuccin Frappé"
  catppuccin-latte     "Catppuccin Latte"
  tokyonight-night     "Tokyo Night"
  tokyonight-storm     "Tokyo Night Storm"
  tokyonight-moon      "Tokyo Night Moon"
  tokyonight-day       "Tokyo Night Light"
)

# slug -> opencode theme. opencode built-ins are coarse (tokyonight/catppuccin/
# nord/one-dark collapse flavors), so map exact where a built-in exists and fall
# back to "system" (opencode's terminal-ANSI-adaptive theme -- the herdr
# `terminal` equivalent; since Ghostty's ANSI is themed per-slug, it tracks well).
# poimandres is a custom JSON already in ~/.config/opencode/themes/. Drop more
# custom JSONs there to tighten the `system` fallbacks over time.
typeset -gA THEME_OPENCODE=(
  poimandres           poimandres            # custom JSON already installed
  nord                 nord
  rose-pine            system                # no built-in; Ghostty ANSI is rose-pine. tune
  rose-pine-moon       system
  rose-pine-dawn       system
  catppuccin-mocha     catppuccin            # opencode's catppuccin == mocha
  catppuccin-macchiato catppuccin-macchiato
  catppuccin-frappe    catppuccin            # no frappe built-in; tune
  catppuccin-latte     system                # no latte/light built-in; tune
  tokyonight-night     tokyonight
  tokyonight-storm     tokyonight
  tokyonight-moon      tokyonight
  tokyonight-day       system                # no tokyo light built-in; tune
)
