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
  gruvbox-dark gruvbox-light
  solarized-dark solarized-light
  one-dark one-light
  dracula
  kanagawa-wave kanagawa-lotus
  ayu-dark ayu-mirage ayu-light
  everforest-dark everforest-light
  night-owl night-owl-light
  monokai-pro
  github-dark github-light
  vesper
  melange-dark melange-light
  synthwave-84
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
  gruvbox-dark         "Gruvbox Dark"
  gruvbox-light        "Gruvbox Light"
  solarized-dark       "iTerm2 Solarized Dark"
  solarized-light      "iTerm2 Solarized Light"
  one-dark             "Atom One Dark"
  one-light            "Atom One Light"
  dracula              "Dracula"
  kanagawa-wave        "Kanagawa Wave"
  kanagawa-lotus       "Kanagawa Lotus"
  ayu-dark             "Ayu"
  ayu-mirage           "Ayu Mirage"
  ayu-light            "Ayu Light"
  everforest-dark      "Everforest Dark Hard"
  everforest-light     "Everforest Light Med"
  night-owl            "Night Owl"
  night-owl-light      "Light Owl"              # Ghostty's Night Owl Light (bg #fbfbfb)
  monokai-pro          "Monokai Pro"
  github-dark          "GitHub Dark Default"
  github-light         "GitHub Light Default"
  vesper               "Vesper"
  melange-dark         "Melange Dark"
  melange-light        "Melange Light"
  synthwave-84         "Synthwave Everything"   # truest match to Robb Owen's Synthwave '84 palette
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
  gruvbox-dark         gruvbox-dark
  gruvbox-light        gruvbox-light
  solarized-dark       "Solarized (dark)"
  solarized-light      "Solarized (light)"
  one-dark             OneHalfDark
  one-light            OneHalfLight
  dracula              Dracula
  kanagawa-wave        gruvbox-dark          # no bat kanagawa; nearest warm-dark; tune (author tmTheme)
  kanagawa-lotus       gruvbox-light         # nearest light; tune
  ayu-dark             TwoDark               # no bat ayu; nearest dark; tune
  ayu-mirage           TwoDark               # nearest; tune
  ayu-light            OneHalfLight          # nearest light; tune
  everforest-dark      gruvbox-dark          # no bat everforest; nearest; tune
  everforest-light     gruvbox-light         # nearest light; tune
  night-owl            night-owl             # custom tmTheme in bat/themes/
  night-owl-light      night-owl-light       # custom tmTheme in bat/themes/
  monokai-pro          "Monokai Extended"    # bat built-in (close to Monokai Pro)
  github-dark          github-dark           # custom tmTheme in bat/themes/
  github-light         "GitHub"              # bat built-in (light GitHub)
  vesper               vesper                # custom tmTheme in bat/themes/
  melange-dark         melange-dark          # custom tmTheme in bat/themes/
  melange-light        melange-light         # custom tmTheme in bat/themes/
  synthwave-84         synthwave-84          # custom tmTheme in bat/themes/
)

# slug -> Neovim colorscheme name (all plugins expose these names directly).
# gruvbox/solarized/everforest use ONE colorscheme name for both light+dark;
# the light/dark split comes from vim.o.background (set by config/theme.lua from
# THEME_ISLIGHT). Plugin specs live in lua/plugins/<family>.lua.
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
  gruvbox-dark         gruvbox
  gruvbox-light        gruvbox
  solarized-dark       solarized
  solarized-light      solarized
  one-dark             onedark
  one-light            onelight
  dracula              dracula
  kanagawa-wave        kanagawa-wave
  kanagawa-lotus       kanagawa-lotus
  ayu-dark             ayu-dark
  ayu-mirage           ayu-mirage
  ayu-light            ayu-light
  everforest-dark      everforest
  everforest-light     everforest
  night-owl            night-owl             # oxfist/night-owl.nvim (dark only)
  night-owl-light      onelight              # no NO Light nvim plugin; nearest light; tune
  monokai-pro          monokai-pro           # loctvl842/monokai-pro.nvim (pro filter)
  github-dark          github_dark_default   # projekt0n/github-nvim-theme
  github-light         github_light_default  # projekt0n/github-nvim-theme
  vesper               vesper                # datsfilipe/vesper.nvim (dark only)
  melange-dark         melange               # savq/melange-nvim (bg drives variant)
  melange-light        melange               # savq/melange-nvim (bg drives variant)
  synthwave-84         synthwave84           # LunarVim/synthwave84.nvim (dark only)
)

# Which slugs are light backgrounds (everything else is treated as dark)
typeset -gA THEME_ISLIGHT=(
  rose-pine-dawn   1
  catppuccin-latte 1
  tokyonight-day   1
  gruvbox-light    1
  solarized-light  1
  one-light        1
  kanagawa-lotus   1
  ayu-light        1
  everforest-light 1
  night-owl-light  1
  github-light     1
  melange-light    1
)

# slug -> herdr built-in theme (`~/.config/herdr/config.toml` [theme] block).
# herdr's built-ins are COARSE — this is the escape hatch: map to an exact
# built-in when one exists, to "terminal" (inherit Ghostty's live ANSI palette)
# when none fits, and tune the rest by trial and error over time.
# herdr built-ins: terminal, nord, rose-pine, rose-pine-dawn, catppuccin,
#   catppuccin-latte, tokyo-night, tokyo-night-day, dracula, gruvbox,
#   gruvbox-light, one-dark, one-light, solarized, solarized-light,
#   kanagawa, kanagawa-lotus, vesper. (No poimandres; catppuccin & tokyonight
#   each collapse to a single flavor; no rose-pine-moon; no ayu/everforest.)
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
  gruvbox-dark         gruvbox           # exact
  gruvbox-light        gruvbox-light     # exact
  solarized-dark       solarized         # exact
  solarized-light      solarized-light   # exact
  one-dark             one-dark          # exact
  one-light            one-light         # exact
  dracula              dracula           # exact
  kanagawa-wave        kanagawa          # exact
  kanagawa-lotus       kanagawa-lotus    # exact
  ayu-dark             terminal          # no herdr ayu -> terminal; tune
  ayu-mirage           terminal          # -> terminal
  ayu-light            terminal          # -> terminal
  everforest-dark      terminal          # no herdr everforest -> terminal; tune
  everforest-light     terminal          # -> terminal
  night-owl            terminal          # -> terminal
  night-owl-light      one-light         # -> one-light
  monokai-pro          terminal          # terminal
  github-dark          terminal          # terminal
  github-light         terminal          # -> terminal
  vesper               vesper            # exact (herdr ships vesper)
  melange-dark         gruvbox           # gruvbox
  melange-light        terminal          # -> terminal
  synthwave-84         terminal          # no herdr synthwave -> Ghostty ANSI; tune
)

# slug -> hunk theme. hunk's ids are the BUNDLED SHIKI THEME IDS (verified from
# hunk's src: HUNK_DIFF_THEME_NAMES = BUNDLED_SHIKI_THEME_IDS). Map to an exact
# shiki id where one exists; an unknown id makes hunk fall back to
# github-dark-default (the "stuck default" bug), so never guess.
# Relevant shiki ids: poimandres, nord, rose-pine{,-moon,-dawn},
#   catppuccin-{mocha,macchiato,frappe,latte}, tokyo-night, dracula{,-soft},
#   gruvbox-{dark,light}-{hard,medium,soft}, solarized-{dark,light},
#   one-dark-pro, one-light, monokai, ayu-dark, kanagawa-{wave,dragon,lotus},
#   everforest-{dark,light}, github-{dark,light}-default, night-owl, vesper.
#   (No ayu-mirage/ayu-light, no tokyo light -> those fall back below.)
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
  tokyonight-day       github-light-default  # no tokyo light in shiki; tune (one-light/solarized-light)
  gruvbox-dark         gruvbox-dark-medium   # shiki (no plain gruvbox-dark)
  gruvbox-light        gruvbox-light-medium  # shiki
  solarized-dark       solarized-dark        # shiki
  solarized-light      solarized-light       # shiki
  one-dark             one-dark-pro          # shiki
  one-light            one-light             # shiki
  dracula              dracula               # shiki
  kanagawa-wave        kanagawa-wave         # shiki
  kanagawa-lotus       kanagawa-lotus        # shiki
  ayu-dark             ayu-dark              # shiki
  ayu-mirage           ayu-dark              # no shiki ayu-mirage; nearest; tune
  ayu-light            github-light-default  # no shiki ayu-light; tune
  everforest-dark      everforest-dark       # shiki
  everforest-light     everforest-light      # shiki
  night-owl            night-owl             # shiki (exact)
  night-owl-light      github-light-default  # no shiki night-owl light; nearest light; tune
  monokai-pro          monokai               # shiki `monokai` (regular; near Pro); tune
  github-dark          github-dark-default   # shiki (exact)
  github-light         github-light-default  # shiki (exact)
  vesper               vesper                # shiki (exact)
  melange-dark         gruvbox-dark-medium   # no shiki melange; nearest warm-dark; tune
  melange-light        vitesse-light         # -> vitesse-light
  synthwave-84         synthwave-84          # shiki (exact)
)

# slug -> vivid theme (generates LS_COLORS; drives eza, ls, fd, and the fzf file
# previews). vivid 0.11 built-ins: nord, rose-pine{,-moon,-dawn}, catppuccin-*,
# tokyonight-*, gruvbox-{dark,light}(+hard/soft), solarized-{dark,light},
# one-dark, one-light, dracula, ayu, molokai, snazzy, zenburn, iceberg-*, etc.
# (No poimandres/kanagawa/everforest -> nearest; tune.)
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
  gruvbox-dark         gruvbox-dark
  gruvbox-light        gruvbox-light
  solarized-dark       solarized-dark
  solarized-light      solarized-light
  one-dark             one-dark
  one-light            one-light
  dracula              dracula
  kanagawa-wave        zenburn               # no vivid kanagawa; nearest muted-dark; tune
  kanagawa-lotus       gruvbox-light         # nearest light; tune
  ayu-dark             ayu
  ayu-mirage           ayu                   # vivid has a single ayu
  ayu-light            gruvbox-light         # vivid ayu is dark; nearest light; tune
  everforest-dark      gruvbox-dark          # no vivid everforest; nearest; tune
  everforest-light     gruvbox-light         # nearest light; tune
  night-owl            tokyonight-night      # no vivid night-owl; nearest navy-dark; tune
  night-owl-light      one-light             # nearest neutral light; tune
  monokai-pro          molokai               # vivid's monokai; tune
  github-dark          one-dark              # no vivid github; nearest neutral-dark; tune
  github-light         modus-operandi        # clean neutral light ~ github light; tune
  vesper               zenburn               # no vivid vesper; nearest warm-muted-dark; tune
  melange-dark         gruvbox-dark          # no vivid melange; nearest warm-dark; tune
  melange-light        gruvbox-light         # nearest warm-light; tune
  synthwave-84         cyberdream            # no vivid synthwave; nearest neon-dark; tune
)

# slug -> btop theme name (the color_theme value = a .theme file stem in
# ~/.config/btop/themes/, or a btop built-in). Catppuccin/Rose Pine/TokyoNight
# .theme files were fetched from their official repos; nord + tokyo-night ship
# with btop, as do gruvbox_*, solarized_*, onedark, dracula, kanagawa-*, ayu,
# everforest-*-medium. poimandres has none -> tokyo-night. Light gaps (one-light,
# ayu-light) -> nearest neutral-light "paper"; ayu-mirage -> "ayu".
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
  gruvbox-dark         gruvbox_dark          # btop built-in
  gruvbox-light        gruvbox_light         # btop built-in
  solarized-dark       solarized_dark        # btop built-in
  solarized-light      solarized_light       # btop built-in
  one-dark             onedark               # btop built-in
  one-light            paper                 # no btop one-light; nearest neutral-light; tune
  dracula              dracula               # btop built-in
  kanagawa-wave        kanagawa-wave         # btop built-in
  kanagawa-lotus       kanagawa-lotus        # btop built-in
  ayu-dark             ayu                   # btop built-in
  ayu-mirage           ayu                   # no btop ayu-mirage; use ayu; tune
  ayu-light            paper                 # no btop ayu-light; nearest neutral-light; tune
  everforest-dark      everforest-dark-medium
  everforest-light     everforest-light-medium
  night-owl            night-owl             # btop built-in .theme
  night-owl-light      paper                 # no btop night-owl light; nearest neutral-light; tune
  monokai-pro          monokai               # btop built-in .theme
  github-dark          onedark               # no btop github; nearest neutral-dark; tune
  github-light         paper                 # no btop github light; nearest neutral-light; tune
  vesper               onedark               # no btop vesper; nearest minimal-dark; tune
  melange-dark         gruvbox_dark          # no btop melange; nearest warm-dark; tune
  melange-light        gruvbox_light         # no btop melange; nearest warm-light; tune
  synthwave-84         dracula               # no btop synthwave; nearest vibrant-purple-dark; tune
)

# slug -> Zed theme display name (EXACT strings from each theme extension -- the
# accents/qualifiers matter, or Zed silently keeps the previous theme). Bundled:
# Gruvbox, One, Ayu. Extensions (auto_install_extensions in settings.json):
# catppuccin, rose-pine-theme, tokyo-night, nord, poimandres, solarized,
# dracula, kanagawa-themes, everforest. Zed hot-reloads settings.json and flips
# light/dark natively when theme.mode = "system".
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
  gruvbox-dark         "Gruvbox Dark"        # bundled
  gruvbox-light        "Gruvbox Light"       # bundled
  solarized-dark       "Solarized Dark"      # solarized ext (verify name in Zed picker)
  solarized-light      "Solarized Light"     # solarized ext
  one-dark             "One Dark"            # bundled
  one-light            "One Light"           # bundled
  dracula              "Dracula"             # dracula ext
  kanagawa-wave        "Kanagawa Wave"       # kanagawa-themes ext
  kanagawa-lotus       "Kanagawa Lotus"      # kanagawa-themes ext
  ayu-dark             "Ayu Dark"            # bundled
  ayu-mirage           "Ayu Mirage"          # bundled
  ayu-light            "Ayu Light"           # bundled
  everforest-dark      "Everforest Dark Medium (regular)"   # everforest ext
  everforest-light     "Everforest Light Medium (regular)"  # everforest ext
  night-owl            "Night Owl Dark"      # night-owlz ext
  night-owl-light      "Night Owl Light"     # night-owlz ext
  monokai-pro          "Monokai Pro (CE)"    # monokai-pro-ce ext (single theme, incl. " (CE)")
  github-dark          "GitHub Dark"         # github-theme ext (closest registry pair to Dark Default)
  github-light         "GitHub Light"        # github-theme ext (closest registry pair to Light Default)
  vesper               "Vesper"              # vesper ext
  melange-dark         "Melange Dark"        # melange ext
  melange-light        "Melange Light"       # melange ext
  synthwave-84         "Synthwave84"         # synthwave84 ext (NO space/apostrophe)
)

# slug -> opencode theme. opencode built-ins are coarse (tokyonight/catppuccin/
# nord/one-dark/gruvbox/kanagawa/ayu/everforest, all dark), so map exact where a
# built-in exists and fall back to "system" (opencode's terminal-ANSI-adaptive
# theme -- the herdr `terminal` equivalent; since Ghostty's ANSI is themed
# per-slug, it tracks well). Every LIGHT slug -> system (no light built-ins).
# poimandres is a custom JSON in ~/.config/opencode/themes/. Drop more custom
# JSONs there to tighten the `system` fallbacks over time.
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
  gruvbox-dark         gruvbox
  gruvbox-light        system                # opencode gruvbox is dark; light -> system
  solarized-dark       system                # no opencode solarized; tune (custom JSON)
  solarized-light      system
  one-dark             one-dark
  one-light            system                # one-dark is dark; light -> system
  dracula              system                # no opencode dracula; tune (custom JSON)
  kanagawa-wave        kanagawa
  kanagawa-lotus       system                # kanagawa built-in is dark; lotus -> system
  ayu-dark             ayu
  ayu-mirage           ayu
  ayu-light            system                # ayu light -> system
  everforest-dark      everforest
  everforest-light     system                # everforest built-in is dark; light -> system
  night-owl            system                # no opencode night-owl; Ghostty ANSI. tune (custom JSON)
  night-owl-light      system                # no light built-in -> system
  monokai-pro          system                # no opencode monokai; Ghostty ANSI. tune
  github-dark          system                # no opencode github; Ghostty ANSI. tune
  github-light         system                # no light built-in -> system
  vesper               system                # no opencode vesper; Ghostty ANSI. tune
  melange-dark         system                # no opencode melange; Ghostty ANSI. tune
  melange-light        system                # no light built-in -> system
  synthwave-84         system                # no opencode synthwave; Ghostty ANSI. tune
)
