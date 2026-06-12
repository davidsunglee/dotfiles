#!/usr/bin/env bash
# Claude Code statusLine command
# Layout: model thinking • cwd • context ctx% used ctxSize window
#   model + thinking level  -> pastel blue
#   cwd                     -> pastel green
#   context label + % + window size -> pastel yellow
#   group separator         -> subtle gray dot

input=$(cat)

# --- extract fields -------------------------------------------------------
model=$(echo "$input"   | jq -r '.model.display_name // empty')
# Keep only name + version: strip parenthetical/bracketed extras like "(1M context)" or "[1m]"
model=$(echo "$model" | sed -E 's/ *\([^)]*\)//g; s/ *\[[^]]*\]//g; s/ +$//')
# Lower-case the model name
model=$(echo "$model" | tr '[:upper:]' '[:lower:]')
effort=$(echo "$input"  | jq -r '.effort.level // empty')
thinking=$(echo "$input" | jq -r '.thinking.enabled // empty')

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
if [[ -n "$HOME" && "$cwd" == "$HOME"* ]]; then
  cwd="~${cwd#$HOME}"
fi

ctx_pct=$(echo "$input"  | jq -r '.context_window.used_percentage // empty')
ctx_size=$(echo "$input" | jq -r '.context_window.context_window_size // empty')

# --- helpers --------------------------------------------------------------
# Human-readable token count: 1000000 -> 1M, 200000 -> 200K
fmt_size() {
  local n=$1
  [[ -z "$n" || "$n" == "null" ]] && return
  if (( n >= 1000000 )); then
    if (( n % 1000000 == 0 )); then printf '%dM' "$((n / 1000000))"; else printf '%.1fM' "$(awk "BEGIN{print $n/1000000}")"; fi
  elif (( n >= 1000 )); then
    printf '%dK' "$((n / 1000))"
  else
    printf '%d' "$n"
  fi
}

# --- colors (256-color pastels) -------------------------------------------
BLUE='\033[38;5;117m'    # pastel blue
GREEN='\033[38;5;151m'   # pastel green
ORANGE='\033[38;5;215m'  # pastel orange
YELLOW='\033[38;5;222m'  # pastel yellow
GRAY='\033[38;5;244m'    # subtle gray
RESET='\033[0m'
DOT=" ${GRAY}•${RESET} "

# --- assemble segments ----------------------------------------------------
segments=()

# 1+2. model + thinking level (pastel blue)
model_seg=""
[[ -n "$model" ]] && model_seg="$model"
think_label=""
if [[ -n "$effort" ]]; then
  think_label="$effort"
elif [[ "$thinking" == "true" ]]; then
  think_label="thinking"
fi
if [[ -n "$think_label" ]]; then
  model_seg="${model_seg:+$model_seg }$think_label"
fi
[[ -n "$model_seg" ]] && segments+=("${BLUE}${model_seg}${RESET}")

# 3. cwd (pastel green)
[[ -n "$cwd" ]] && segments+=("${GREEN}${cwd}${RESET}")

# 4+5. context % used  •  window size (pastel yellow, gray dot between)
ctx_used=""
[[ -n "$ctx_pct" && "$ctx_pct" != "null" ]] && ctx_used="${ctx_pct}% used"
ctx_win=""
size_h="$(fmt_size "$ctx_size")"
[[ -n "$size_h" ]] && ctx_win="${size_h} window"
# Lead with the label so it's clear what the numbers refer to (attach to the first present part)
if [[ -n "$ctx_used" ]]; then
  ctx_used="context $ctx_used"
elif [[ -n "$ctx_win" ]]; then
  ctx_win="context $ctx_win"
fi
ctx_parts=()
[[ -n "$ctx_used" ]] && ctx_parts+=("${YELLOW}${ctx_used}${RESET}")
[[ -n "$ctx_win"  ]] && ctx_parts+=("${YELLOW}${ctx_win}${RESET}")
ctx_joined=""
for p in "${ctx_parts[@]}"; do
  ctx_joined="${ctx_joined:+$ctx_joined$DOT}$p"
done
[[ -n "$ctx_joined" ]] && segments+=("$ctx_joined")

# --- join with gray dot ---------------------------------------------------
out=""
for seg in "${segments[@]}"; do
  out="${out:+$out$DOT}$seg"
done
printf '%b' "$out"
