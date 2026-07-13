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
  # LS_COLORS via vivid -> colours eza (ll/la + fzf tree previews), ls, and fd.
  # Cached per-slug so precmd/startup is a file read, not a vivid subprocess;
  # `theme reload` drops the cache so THEME_VIVID edits take effect.
  local lc="$THEME_DIR/cache/lscolors-$slug"
  if [[ ! -s "$lc" ]] && (( $+commands[vivid] )); then
    mkdir -p "${lc:h}"
    vivid generate "${THEME_VIVID[$slug]:-one-dark}" >| "$lc" 2>/dev/null || rm -f "$lc"
  fi
  [[ -s "$lc" ]] && export LS_COLORS="$(<"$lc")"
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

# --- herdr (rewrites the fenced [theme] block; reloads a running server) -----
# herdr's config is large & user-owned, so we surgically replace only the block
# between the theme-controller fence markers (added to config.toml). Not pinned:
# auto_switch=true + dark_name/light_name so herdr flips light/dark natively.
# Pinned: a single forced name. Slugs map through THEME_HERDR (edit that map).
_theme_write_herdr() {
  local conf="$HOME/.config/herdr/config.toml"
  [[ -f "$conf" ]] || return 0
  grep -q '^# >>> theme-controller' "$conf" || return 0   # no fence -> leave file alone
  # NB: \n kept as literal backslash-n so awk (BSD/macOS) expands it; a real
  # newline in an awk -v value is a hard error ("newline in string").
  local pin block
  pin="$(_theme_get pin)"
  if [[ -n "$pin" ]]; then
    block='[theme]\nname = "'"${THEME_HERDR[$pin]:-terminal}"'"\nauto_switch = false'
  else
    local eff dark light
    eff="$(_theme_effective)"; dark="$(_theme_get dark)"; light="$(_theme_get light)"
    block='[theme]\nname = "'"${THEME_HERDR[$eff]:-terminal}"'"\nauto_switch = true\ndark_name = "'"${THEME_HERDR[$dark]:-terminal}"'"\nlight_name = "'"${THEME_HERDR[$light]:-terminal}"'"'
  fi
  local tmp="$conf.$$"
  awk -v block="$block" '
    /^# >>> theme-controller/ { print; print block; skip=1; next }
    /^# <<< theme-controller/ { skip=0; print; next }
    !skip { print }
  ' "$conf" > "$tmp" && mv "$tmp" "$conf"
  # Push to a running server (no-op/harmless if none). Backgrounded & disowned.
  command herdr server reload-config >/dev/null 2>&1 &|
}

# --- hunk (rewrites the fenced theme line) -----------------------------------
# hunk has no theme env var and its `auto` mode is unreliable (OSC bg query),
# so we write an explicit `theme = "<id>"`. hunk reads config at each launch, so
# this just needs to be current — kept in sync on OS flips via the precmd hook.
_theme_write_hunk() {
  local conf="$HOME/.config/hunk/config.toml"
  [[ -f "$conf" ]] || return 0
  grep -q '^# >>> theme-controller' "$conf" || return 0
  local slug="${1:-$(_theme_effective)}" name
  name="${THEME_HUNK[$slug]:-github-dark-default}"
  grep -q "^theme = \"$name\"$" "$conf" && return 0        # already current -> skip write
  local tmp="$conf.$$"
  awk -v line="theme = \"$name\"" '
    /^# >>> theme-controller/ { print; print line; skip=1; next }
    /^# <<< theme-controller/ { skip=0; print; next }
    !skip { print }
  ' "$conf" > "$tmp" && mv "$tmp" "$conf"
}

# --- btop (rewrites the single color_theme line) -----------------------------
# btop has no theme env var and reads its config at launch, so we keep the
# color_theme key current (synced on OS flips via the precmd hook). Not fenced:
# color_theme is a single well-known key, so we replace just that line. Slugs
# map through THEME_BTOP; the named .theme files live in ~/.config/btop/themes/.
_theme_write_btop() {
  local conf="$HOME/.config/btop/btop.conf"
  [[ -f "$conf" ]] || return 0
  local slug="${1:-$(_theme_effective)}" name
  name="${THEME_BTOP[$slug]:-Default}"
  grep -q "^color_theme = \"$name\"\$" "$conf" && return 0   # already current
  local tmp="$conf.$$"
  awk -v v="color_theme = \"$name\"" '
    /^color_theme = / { print v; next }
    { print }
  ' "$conf" > "$tmp" && mv "$tmp" "$conf"
}

# --- Zed (rewrites the single-line "theme" object in settings.json) -----------
# Zed watches settings.json and hot-reloads; with theme.mode="system" it flips
# light/dark natively, so this only needs rewriting when the slots/pin change
# (via _theme_propagate), NOT on every OS flip. settings.json is JSONC; we keep
# the theme value on ONE line so a line-oriented replace is safe. Extensions are
# installed by the auto_install_extensions block (set up once, not touched here).
_theme_write_zed() {
  local conf="$HOME/.config/zed/settings.json"
  [[ -f "$conf" ]] || return 0
  grep -q '^[[:space:]]*"theme":' "$conf" || return 0        # nothing to manage
  local pin line
  pin="$(_theme_get pin)"
  if [[ -n "$pin" ]]; then
    local mode="dark"; [[ -n "${THEME_ISLIGHT[$pin]}" ]] && mode="light"
    local nm="${THEME_ZED[$pin]:-One Dark}"
    line="  \"theme\": { \"mode\": \"$mode\", \"light\": \"$nm\", \"dark\": \"$nm\" },"
  else
    local d l
    d="${THEME_ZED[$(_theme_get dark)]:-One Dark}"; l="${THEME_ZED[$(_theme_get light)]:-One Light}"
    line="  \"theme\": { \"mode\": \"system\", \"light\": \"$l\", \"dark\": \"$d\" },"
  fi
  grep -qF -- "$line" "$conf" && return 0                    # already current
  local tmp="$conf.$$"
  awk -v line="$line" '
    /^[[:space:]]*"theme":/ { print line; next }
    { print }
  ' "$conf" > "$tmp" && mv "$tmp" "$conf"
}

# --- opencode (rewrites the fenced "theme" key in opencode.jsonc) -------------
# opencode reads config at launch and has no theme env var, so we keep the theme
# key current (synced on OS flips via the precmd hook). opencode.jsonc is JSONC
# (comments OK); the managed key sits between // fence markers, placed first with
# a trailing comma so it stays valid whatever other keys follow. THEME_OPENCODE
# falls back to "system" (terminal-ANSI-adaptive) where no exact built-in fits.
_theme_write_opencode() {
  local conf="$HOME/.config/opencode/opencode.jsonc"
  [[ -f "$conf" ]] || return 0
  grep -q '// >>> theme-controller' "$conf" || return 0
  local slug="${1:-$(_theme_effective)}" name
  name="${THEME_OPENCODE[$slug]:-system}"
  grep -q "^  \"theme\": \"$name\",\$" "$conf" && return 0   # already current
  local tmp="$conf.$$"
  awk -v line="  \"theme\": \"$name\"," '
    /\/\/ >>> theme-controller/ { print; print line; skip=1; next }
    /\/\/ <<< theme-controller/ { skip=0; print; next }
    !skip { print }
  ' "$conf" > "$tmp" && mv "$tmp" "$conf"
}

# --- propagate a change to every tool ---------------------------------------
# fzf/bat/delta/LS_COLORS follow via env (_theme_env); Ghostty, herdr, hunk,
# btop, Zed, opencode via their config files. Neovim polls; lazygit reads at
# launch — no writers needed here.
_theme_propagate() {
  _theme_env
  _theme_write_ghostty
  _theme_write_herdr
  _theme_write_hunk
  _theme_write_btop
  _theme_write_zed
  _theme_write_opencode
}

# --- precmd hook: keep this shell's env in sync with OS appearance -----------
typeset -g _THEME_CUR=""
_theme_precmd() {
  local slug; slug="$(_theme_effective)"
  [[ "$slug" == "$_THEME_CUR" ]] && return
  _THEME_CUR="$slug"
  _theme_env "$slug"
  # Launch-only tools that can't self-flip: keep their config files current on OS
  # flips. (Ghostty/herdr/Zed flip natively, so they're not rewritten here.)
  _theme_write_hunk "$slug"
  _theme_write_btop "$slug"
  _theme_write_opencode "$slug"
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
    reload)
      # Re-source the maps (after editing any THEME_* map) and re-apply. Drop the
      # LS_COLORS cache so THEME_VIVID edits take effect.
      rm -rf "$THEME_DIR/cache"
      source "$THEME_DIR/registry.zsh"; source "$THEME_DIR/apply.zsh"; _theme_propagate
      print -r -- "reloaded registry maps and re-applied (effective: $(_theme_effective))."
      ;;
    list)
      local s; for s in $THEME_SLUGS; do
        local tag=""; [[ -n "${THEME_ISLIGHT[$s]}" ]] && tag=" (light)"
        print -r -- "  $s$tag"
      done
      ;;
    *)
      print -r -- "usage: theme [show | dark <slug> | light <slug> | pin <slug> | auto | reload | list]" >&2
      return 2
      ;;
  esac
}

# completion: slugs for dark/light/pin
_theme() {
  local -a subs=(show dark light pin auto reload list)
  if (( CURRENT == 2 )); then
    compadd -- $subs
  elif (( CURRENT == 3 )) && [[ "$words[2]" == (dark|light|pin) ]]; then
    compadd -- $THEME_SLUGS
  fi
}
