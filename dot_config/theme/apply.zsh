# Theme controller functions. Sourced by ~/.config/theme/init.zsh (after registry.zsh).

typeset -g THEME_DIR="${THEME_DIR:-$HOME/.config/theme}"
typeset -g THEME_STATE="$THEME_DIR/state"
# Structural fzf opts shared by every theme; the per-theme palette is appended.
typeset -g FZF_STRUCTURAL="--highlight-line --info=inline-right --ansi --layout=reverse --border=none"

# --- state file access -------------------------------------------------------
_theme_get() {  # _theme_get <key> -> value on stdout (empty ok)
  [[ -r "$THEME_STATE" ]] || return 1
  local k v
  while IFS='=' read -r k v; do
    [[ "$k" == "$1" ]] && { print -r -- "$v"; return 0 }
  done < "$THEME_STATE"
  return 1
}

_theme_set() {  # _theme_set <key> <value>  (rewrites state, preserving other keys)
  local key="$1" val="$2" tmp="$THEME_STATE.$$" k v found=0
  [[ -f "$THEME_STATE" ]] || : > "$THEME_STATE"
  {
    while IFS='=' read -r k v; do
      [[ -z "$k" ]] && continue
      if [[ "$k" == "$key" ]]; then print -r -- "$key=$val"; found=1
      else print -r -- "$k=$v"; fi
    done < "$THEME_STATE"
    (( found )) || print -r -- "$key=$val"
  } > "$tmp" && mv "$tmp" "$THEME_STATE"
}

# --- resolution --------------------------------------------------------------
_theme_appearance() {  # -> "dark" | "light" (macOS)
  [[ "$(defaults read -g AppleInterfaceStyle 2>/dev/null)" == Dark ]] && print -r -- dark || print -r -- light
}

_theme_effective() {  # -> the slug that should currently be active
  local pin; pin="$(_theme_get pin)"
  if [[ -n "$pin" ]]; then print -r -- "$pin"; return; fi
  [[ "$(_theme_appearance)" == dark ]] && _theme_get dark || _theme_get light
}

_theme_valid() {  # _theme_valid <slug> -> 0 if known
  (( ${THEME_SLUGS[(Ie)$1]} ))
}

# --- per-shell environment (fzf / bat / delta-syntax) ------------------------
_theme_env() {  # _theme_env [slug]  (defaults to effective); cheap, precmd-safe
  local slug="${1:-$(_theme_effective)}"
  [[ -n "$slug" ]] || return
  export THEME_SLUG="$slug"
  export BAT_THEME="${THEME_BAT[$slug]:-$slug}"          # bat + delta syntax-theme
  # delta decoration light/dark (features defined in ~/.gitconfig); lazygit inherits this
  if [[ -n "${THEME_ISLIGHT[$slug]}" ]]; then
    export DELTA_FEATURES="+delta-light"
  else
    export DELTA_FEATURES="+delta-dark"
  fi
  local pf="$HOME/.config/fzf/themes/$slug.fzf"
  [[ -r "$pf" ]] && export FZF_DEFAULT_OPTS="$FZF_STRUCTURAL $(tr '\n' ' ' < "$pf")"
}

# --- Ghostty (writes the light/dark pair, or a single pinned theme) ----------
_theme_write_ghostty() {
  local conf="$HOME/.config/ghostty/theme.conf" pin
  [[ -d "${conf:h}" ]] || return 0
  pin="$(_theme_get pin)"
  if [[ -n "$pin" ]]; then
    print -r -- "theme = ${THEME_GHOSTTY[$pin]}" > "$conf"
  else
    print -r -- "theme = light:${THEME_GHOSTTY[$(_theme_get light)]},dark:${THEME_GHOSTTY[$(_theme_get dark)]}" > "$conf"
  fi
}

# --- propagate a change to every tool ---------------------------------------
# fzf/bat/delta follow via env (_theme_env); Ghostty via theme.conf. Neovim,
# lazygit, herdr (terminal mode), and hunk (auto) follow on their own — no
# per-tool writers needed here.
_theme_propagate() {
  _theme_env
  _theme_write_ghostty
}

# --- precmd hook: keep this shell's env in sync with OS appearance -----------
typeset -g _THEME_CUR=""
_theme_precmd() {
  local slug; slug="$(_theme_effective)"
  [[ "$slug" == "$_THEME_CUR" ]] && return
  _THEME_CUR="$slug"
  _theme_env "$slug"
}

# --- user-facing command -----------------------------------------------------
theme() {
  local sub="${1:-show}"
  case "$sub" in
    show|status|"")
      local eff; eff="$(_theme_effective)"
      print -r -- "appearance : $(_theme_appearance)"
      print -r -- "dark slot  : $(_theme_get dark)"
      print -r -- "light slot : $(_theme_get light)"
      local pin; pin="$(_theme_get pin)"
      print -r -- "pinned     : ${pin:-(auto — follows appearance)}"
      print -r -- "effective  : $eff"
      ;;
    dark|light)
      if ! _theme_valid "$2"; then print -r -- "theme: unknown slug '$2' (try: theme list)" >&2; return 1; fi
      _theme_set "$sub" "$2"; _theme_propagate
      print -r -- "$sub slot set to '$2'. Reload Ghostty (Cmd+Shift+,) to apply it there."
      ;;
    pin)
      if ! _theme_valid "$2"; then print -r -- "theme: unknown slug '$2' (try: theme list)" >&2; return 1; fi
      _theme_set pin "$2"; _theme_propagate
      print -r -- "pinned to '$2' (ignoring appearance). Reload Ghostty (Cmd+Shift+,) to apply."
      ;;
    auto)
      _theme_set pin ""; _theme_propagate
      print -r -- "back to auto (dark=$(_theme_get dark), light=$(_theme_get light)). Reload Ghostty to apply."
      ;;
    list)
      local s; for s in $THEME_SLUGS; do
        local tag=""; [[ -n "${THEME_ISLIGHT[$s]}" ]] && tag=" (light)"
        print -r -- "  $s$tag"
      done
      ;;
    *)
      print -r -- "usage: theme [show | dark <slug> | light <slug> | pin <slug> | auto | list]" >&2
      return 2
      ;;
  esac
}

# completion: slugs for dark/light/pin
_theme() {
  local -a subs=(show dark light pin auto list)
  if (( CURRENT == 2 )); then
    compadd -- $subs
  elif (( CURRENT == 3 )) && [[ "$words[2]" == (dark|light|pin) ]]; then
    compadd -- $THEME_SLUGS
  fi
}
