#!/usr/bin/env bash
set -euo pipefail

# --------------------------------------------------
# ts-create.sh
# Creates / switches tmux session for a directory
#
# Behavior:
# - If DIR provided -> use it
# - Else choose from ~/.recent_dirs via fzf
# - Optional CMD runs inside new session
# - If inside tmux -> switch-client
# - Else -> attach
#
# Options:
#   --log        enable logging
#   -h, --help   help
# --------------------------------------------------

LOG_ENABLED=0
LOG_FILE="/tmp/tmux-ts.log"

FZF_PATH="${HOME}/.fzf/bin/fzf"
RECENT_DIRS="${HOME}/.recent_dirs"

dir=""
cmd=""

usage() {
  cat <<EOF
Usage:
  $(basename "$0") [--log] [DIR] [CMD]
EOF
}

log_init() {
  ((LOG_ENABLED)) || return 0
  : >"$LOG_FILE"
  exec >>"$LOG_FILE" 2>&1
}

log() {
  ((LOG_ENABLED)) || return 0
  printf '[%s] %s\n' "$(date '+%F %T')" "$*"
}

die() {
  echo "Error: $*" >&2
  log "ERROR: $*"
  exit 1
}

parse_args() {
  while (($#)); do
    case "$1" in
      --log) LOG_ENABLED=1 ;;
      -h | --help)
        usage
        exit 0
        ;;
      --)
        shift
        break
        ;;
      *)
        if [[ -z "$dir" ]]; then
          dir="$1"
        elif [[ -z "$cmd" ]]; then
          cmd="$1"
        else
          cmd+=" $1"
        fi
        ;;
    esac
    shift
  done
}

select_dir() {
  [[ -x "$FZF_PATH" ]] || die "fzf not found: $FZF_PATH"
  [[ -f "$RECENT_DIRS" ]] || return 1

  local recent
  recent="$(tac "$RECENT_DIRS" 2>/dev/null | awk '!seen[$0]++')"
  [[ -n "$recent" ]] || return 1

  printf '%s\n' "$recent" | "$FZF_PATH"
}

build_session_name() {
  local base session i

  # OPTIMIZATION: Use native bash string manipulation instead of 'basename'
  base="${dir##*/}"
  base="${base//./_}"

  # Fallback if directory was root or empty
  session="${base:-main}"

  if ! tmux has-session -t "$session" 2>/dev/null; then
    printf '%s\n' "$session"
    return
  fi

  i=1
  while :; do
    session=$(printf '%s %02d' "$base" "$i")
    if ! tmux has-session -t "$session" 2>/dev/null; then
      printf '%s\n' "$session"
      return
    fi
    ((i++))
  done
}

main() {
  parse_args "$@"
  log_init

  # 1. Resolve Directory
  if [[ -z "$dir" ]]; then
    dir="$(select_dir || true)"
  fi

  [[ -n "$dir" ]] || exit 0
  [[ -d "$dir" ]] || die "Invalid directory: $dir"

  # 2. Get Session Name
  local session
  session="$(build_session_name)"
  log "Using session: $session at $dir"

  # 3. Create & Attach (The Fast Path)
  # If there is a specific command to run inside the new pane
  if [[ -n "$cmd" ]]; then
    tmux new-session -ds "$session" -c "$dir"
    tmux send-keys -t "$session" "$cmd" Enter

    if [[ -n "${TMUX:-}" ]]; then
      exec tmux switch-client -t "$session"
    else
      exec tmux attach -t "$session"
    fi

  # If NO command (Standard Kitty/Thunar startup)
  else
    if [[ -n "${TMUX:-}" ]]; then
      # Already in Tmux: Ensure it exists, then switch
      tmux new-session -ds "$session" -c "$dir" 2>/dev/null || true
      exec tmux switch-client -t "$session"
    else
      # Outside Tmux: Atomic creation + attach via exec for maximum speed
      exec tmux new-session -A -s "$session" -c "$dir"
    fi
  fi
}

main "$@"
