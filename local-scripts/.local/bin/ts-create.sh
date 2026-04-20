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

Examples:
  $(basename "$0")
  $(basename "$0") ~/projects/app
  $(basename "$0") ~/projects/app "nvim ."

Logs:
  $LOG_FILE
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
      --log)
        LOG_ENABLED=1
        ;;
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
  recent="$(
    tac "$RECENT_DIRS" 2>/dev/null | awk '!seen[$0]++'
  )"

  [[ -n "$recent" ]] || return 1

  printf '%s\n' "$recent" | "$FZF_PATH"
}

resolve_dir() {
  if [[ -z "$dir" ]]; then
    dir="$(select_dir || true)"
  fi

  [[ -n "$dir" ]] || exit 0
  [[ -d "$dir" ]] || die "Invalid directory: $dir"
}

build_session_name() {
  local base session i

  base="$(basename "$dir")"
  base="${base//./_}"
  session="$base"

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

create_session() {
  local session="$1"

  log "Creating session: $session"
  log "Directory: $dir"

  tmux new-session -ds "$session" -c "$dir"

  if [[ -n "$cmd" ]]; then
    log "Sending command: $cmd"
    tmux send-keys -t "$session" "$cmd" Enter
  fi
}

attach_session() {
  local session="$1"

  if [[ -n "${TMUX:-}" ]]; then
    log "Switching client: $session"
    exec tmux switch-client -t "$session"
  else
    log "Attaching: $session"
    exec tmux attach -t "$session"
  fi
}

main() {
  parse_args "$@"
  log_init

  log "Starting"

  resolve_dir

  local session
  session="$(build_session_name)"

  log "Using session: $session"

  create_session "$session"
  attach_session "$session"
}

main "$@"
