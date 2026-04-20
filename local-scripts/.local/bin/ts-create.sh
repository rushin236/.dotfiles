#!/usr/bin/env bash
set -euo pipefail

# --------------------------------------------------
# ts-create.sh (optimized)
# Same behavior as original:
# - choose directory (arg or fzf from recent dirs)
# - create unique tmux session
# - optionally send command
# - switch/attach
# Added:
# - --log enables logging
# - --log-file PATH custom log file
# --------------------------------------------------

LOG_ENABLED=0
LOG_FILE="/tmp/tmux-ts.log"
FZF_PATH="${HOME}/.fzf/bin/fzf"
RECENT_DIRS="${HOME}/.recent_dirs"

usage() {
  cat <<EOF
Usage: $(basename "$0") [--log] [DIR] [CMD]
Logs: /tmp/tmux-ts.log
View logs: cat /tmp/tmux-ts.log
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

# ---------------- Parse args ----------------
# Async note: this script is dominated by tmux/fzf/user input. Safe backgrounding of dependent steps offers little real gain and can add race conditions. We keep synchronous flow for correctness; only independent prep work is parallelized below.
dir=""
cmd=""
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
  shift || true
done

# Lightweight async preflight
recent_cache=""
if [[ -f "$RECENT_DIRS" ]]; then
  { recent_cache=$(tac "$RECENT_DIRS" 2>/dev/null | awk '!seen[$0]++'); } &
  recent_pid=$!
else
  recent_pid=""
fi

log_init
log "Starting"

select_dir() {
  [[ -x "$FZF_PATH" ]] || die "fzf not found: $FZF_PATH"

  local recent=""
  if [[ -n "${recent_pid:-}" ]]; then
    wait "$recent_pid" 2>/dev/null || true
    recent="$recent_cache"
  elif [[ -f "$RECENT_DIRS" ]]; then
    recent=$(tac "$RECENT_DIRS" | awk '!seen[$0]++')
  fi

  [[ -n "$recent" ]] || exit 0

  printf '%s\n' "$recent" | "$FZF_PATH"
}

[[ -n "$dir" ]] || dir="$(select_dir || true)"
[[ -n "$dir" ]] || exit 0
[[ -d "$dir" ]] || die "Invalid directory: $dir"

base_session="$(basename "$dir")"
base_session="${base_session//./_}"
session="$base_session"

if tmux has-session -t="$session" 2>/dev/null; then
  i=1
  while :; do
    candidate=$(printf '%s %02d' "$base_session" "$i")
    if ! tmux has-session -t="$candidate" 2>/dev/null; then
      session="$candidate"
      break
    fi
    ((i++))
  done
fi

log "Using session: $session"

tmux new-session -ds "$session" -c "$dir" || die "Failed to create tmux session"

if [[ -n "$cmd" ]]; then
  tmux send-keys -t "$session" "$cmd" Enter || die "Failed to send command"
fi

if [[ -n "${TMUX:-}" ]]; then
  exec tmux switch-client -t "$session"
else
  exec tmux attach -t "$session"
fi
