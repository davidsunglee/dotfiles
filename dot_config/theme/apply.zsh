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

# --- opencode (sets "theme" in cli.json) -------------------------------------
# opencode 2.x keeps TUI settings in ~/.config/opencode/cli.json (pure JSON,
# mode 600, also rewritten by opencode itself when you change settings in-app).
# 1.x's opencode.jsonc "theme" key and tui.json were migrated away (2026-07/10),
# so we set {"theme": {"name", "mode"}} with jq. Every 2.x built-in has light AND
# dark variants picked by mode, so mode follows THEME_ISLIGHT (explicit, since
# mode "system" asks the terminal, which is unreliable inside herdr/Rex). Reads
# config at launch, so precmd keeps it current on OS flips.
_theme_write_opencode() {
  local conf="$HOME/.config/opencode/cli.json"
  [[ -f "$conf" ]] && (( $+commands[jq] )) || return 0
  local slug="${1:-$(_theme_effective)}" name mode=dark
  name="${THEME_OPENCODE[$slug]:-system}"
  [[ -n "${THEME_ISLIGHT[$slug]}" ]] && mode=light
  jq -e --arg n "$name" --arg m "$mode" '.theme.name == $n and .theme.mode == $m' "$conf" >/dev/null 2>&1 && return 0
  local tmp="$conf.$$"
  # cat over the original (not mv) so the file keeps its 600 permissions.
  jq --arg n "$name" --arg m "$mode" '.theme = {name: $n, mode: $m}' "$conf" > "$tmp" 2>/dev/null &&
    cat "$tmp" > "$conf"
  rm -f "$tmp"
}

# --- Rex (the multiplexer app; driven through its client actions) -----------
# Rex renders its own terminals and ignores Ghostty's config. It keeps one light
# and one dark theme in its macOS defaults (com.superlogical.rex), but the running
# app does NOT notice outside `defaults write`s, so every change goes through
# `rex -C <app> do client.theme.*`, which needs Remote Control on (Rex Settings >
# Rex Server). We only READ defaults: Workspace.{light,dark}ThemeID, the forced
# Workspace.appearance (light|dark; absent/auto/system = follows macOS), and
# Workspace.customThemes (JSON data: imported themes with id/appearance/name).
#
# A slug's Rex theme is THEME_REX[slug] (a Rex theme id, e.g. a built-in) or, by
# default, its Ghostty theme file imported once (client.theme.import). Imported
# ids are random per Mac, so we look them up by file name, never store them.
#
# Rex quirks this works around: a theme always lands in the slot matching its own
# light/dark type, and selecting one whose type differs from what Rex is showing
# FORCES Rex out of Auto into that mode, which no action can undo (only Settings).
# So unpinned, we only touch the slot Rex is showing and pick up the other slot at
# the first prompt after a macOS flip (precmd). Pinned, we force Rex's mode to the
# pin's type on purpose; `theme auto` then reminds you to click Auto in Settings.
typeset -g THEME_REX_DEFAULTS="com.superlogical.rex"

_theme_rex_bin() {  # -> path of the rex CLI. Rex only puts it on PATH inside its own
  # terminals, so also try $REX_BIN_DIR and the app's install location (needed
  # from plain Ghostty shells and from Rex's Lua actions).
  local b
  for b in "${commands[rex]}" "${REX_BIN_DIR:+$REX_BIN_DIR/rex}" \
           "$HOME/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS/rex"; do
    [[ -n "$b" && -x "$b" ]] && { print -r -- "$b"; return 0 }
  done
  return 1
}

_theme_rex_client() {  # -> client id of the Rex app on THIS Mac (empty if none)
  "$(_theme_rex_bin)" --autostart=false client ls --json 2>/dev/null | jq -r --argjson uid "$UID" '
    first(.clients[] | select(.info.kind == "app" and .principal.transport == "unix"
                       and .principal.uid == $uid) | .client_id) // empty' 2>/dev/null
}

_theme_rex_custom() {  # -> "id<TAB>appearance<TAB>name" per imported Rex theme
  local tmp="${TMPDIR:-/tmp}/theme-rex.$$.plist"
  defaults export "$THEME_REX_DEFAULTS" "$tmp" 2>/dev/null || return 1
  /usr/libexec/PlistBuddy -c 'Print :Workspace.customThemes' "$tmp" 2>/dev/null |
    jq -r '.[] | [.id, .appearance, (.source.ghosttyFile.fileName // .name)] | @tsv' 2>/dev/null
  rm -f "$tmp"
}

_theme_rex_shown() {  # -> the appearance Rex is showing: "light" | "dark"
  local mode; mode="$(defaults read "$THEME_REX_DEFAULTS" Workspace.appearance 2>/dev/null)"
  [[ "$mode" == (light|dark) ]] && print -r -- "$mode" || _theme_appearance
}

_theme_rex_forced() {  # 0 if Rex is forced into light/dark instead of Auto
  [[ "$(defaults read "$THEME_REX_DEFAULTS" Workspace.appearance 2>/dev/null)" == (light|dark) ]]
}

_theme_ghostty_file() {  # _theme_ghostty_file <name> -> path of that Ghostty theme file
  local f
  for f in "$HOME/.config/ghostty/themes/$1" \
           "/Applications/Ghostty.app/Contents/Resources/ghostty/themes/$1"; do
    [[ -f "$f" ]] && { print -r -- "$f"; return 0 }
  done
  return 1
}

# _theme_write_rex [slug]  Notes go to stderr; precmd runs it backgrounded & silent.
_theme_write_rex() {
  (( $+commands[jq] )) || return 0
  local rex; rex="$(_theme_rex_bin)" || return 0
  local slug="${1:-$(_theme_effective)}" pin client
  [[ -n "$slug" ]] || return 0
  client="$(_theme_rex_client)"; [[ -n "$client" ]] || return 0   # Rex app not running
  pin="$(_theme_get pin)"

  # Resolve the slug to a Rex theme id + its light/dark type (as Rex judges it).
  local id="" kind="" name="" file="" line
  if [[ -n "${THEME_REX[$slug]}" ]]; then
    id="${THEME_REX[$slug]}"
    kind=dark; [[ -n "${THEME_ISLIGHT[$slug]}" ]] && kind=light
  else
    name="${THEME_GHOSTTY[$slug]}"
    for line in "${(@f)$(_theme_rex_custom)}"; do
      [[ "${line##*$'\t'}" == "$name" ]] || continue
      id="${line%%$'\t'*}"; kind="${${line#*$'\t'}%%$'\t'*}"; break
    done
    if [[ -z "$id" ]]; then   # not imported yet; Rex will judge its type on import
      file="$(_theme_ghostty_file "$name")" || { print -r -- "theme: no Ghostty theme file '$name' to import into Rex" >&2; return 1 }
      kind=dark; [[ -n "${THEME_ISLIGHT[$slug]}" ]] && kind=light
    fi
  fi

  local shown; shown="$(_theme_rex_shown)"
  if [[ "$kind" != "$shown" ]]; then
    if [[ -z "$pin" ]]; then
      # Unpinned: selecting it would knock Rex out of Auto. Leave Rex alone.
      print -r -- "theme: Rex is showing its $shown theme; '$slug' is a $kind theme, so Rex was left unchanged" >&2
      return 0
    fi
    "$rex" --autostart=false -C "$client" do client.appearance.switch_mode mode="$kind" >/dev/null 2>&1 || {
      print -r -- "theme: Rex isn't accepting actions; turn on Remote Control in Rex Settings > Rex Server" >&2; return 1 }
  fi

  if [[ -n "$id" ]]; then
    [[ "$(defaults read "$THEME_REX_DEFAULTS" "Workspace.${kind}ThemeID" 2>/dev/null)" == "$id" ]] && return 0
    "$rex" --autostart=false -C "$client" do client.theme.change name="$id" >/dev/null 2>&1
  else
    "$rex" --autostart=false -C "$client" do client.theme.import path="$file" >/dev/null 2>&1
  fi || { print -r -- "theme: Rex isn't accepting actions; turn on Remote Control in Rex Settings > Rex Server" >&2; return 1 }
}

# --- propagate a change to every tool ---------------------------------------
# fzf/bat/delta/LS_COLORS follow via env (_theme_env); Ghostty, herdr, hunk,
# btop, Zed, opencode via their config files; Rex via its client actions.
# Neovim polls; lazygit reads at launch — no writers needed here.
_theme_propagate() {
  _theme_env
  _theme_write_ghostty
  _theme_write_herdr
  _theme_write_hunk
  _theme_write_btop
  _theme_write_zed
  _theme_write_opencode
  _theme_write_rex
  # Everything precmd would do on a slug change is done; don't let the next
  # prompt redo it (a second Rex import before Rex saves the first = duplicate).
  _THEME_CUR="$(_theme_effective)"
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
  # Rex flips natively between its two slots; this catches up a slot that was
  # changed while Rex wasn't showing it. Backgrounded: it makes a few rex calls.
  _theme_write_rex "$slug" >/dev/null 2>&1 &|
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
      if defaults read "$THEME_REX_DEFAULTS" >/dev/null 2>&1; then
        if _theme_rex_forced; then
          print -r -- "rex        : forced $(_theme_rex_shown) (set Color scheme to Auto in Rex Settings to follow appearance)"
        else
          print -r -- "rex        : auto — follows appearance"
        fi
      fi
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
      _theme_rex_forced && print -r -- "Rex is still forced to $(_theme_rex_shown): set Settings > Interface > Appearance > Color scheme to Auto (no command can)."
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
