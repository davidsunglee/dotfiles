# Unified theme system entrypoint — sourced from ~/.zshrc.
# Drives Ghostty, fzf, bat, delta, Neovim, herdr, hunk, lazygit from one state
# file (~/.config/theme/state) + macOS light/dark appearance.
# Command: `theme` (run `theme` with no args for status; `theme list` for slugs).

typeset -g THEME_DIR="${THEME_DIR:-$HOME/.config/theme}"

source "$THEME_DIR/registry.zsh"
source "$THEME_DIR/apply.zsh"

# Apply the current theme to THIS shell's env (fzf/bat/delta) and keep it in
# sync with appearance changes on every prompt.
autoload -Uz add-zsh-hook
add-zsh-hook precmd _theme_precmd
_theme_precmd

# Tab-completion for the `theme` command.
compdef _theme theme 2>/dev/null
