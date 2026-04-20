#!/usr/bin/env bash

set -euo pipefail

LOG_ENABLED=0
LOG_FILE="/tmp/recent-dir.log"

# --------------------------------------------------
# recent_dir_v2.sh
# Optimized recent directory launcher
# Preserves behavior of original script
# --------------------------------------------------

RECENT_DIR_FILE="$HOME/.recent_dirs"

usage() {
  cat <<EOF
Usage: $(basename "$0") [--log]
Logs: /tmp/recent-dir.log
View logs: cat /tmp/recent-dir.log
EOF
}

log_init() {
  ((LOG_ENABLED)) || return 0
  : >"$LOG_FILE"
  exec >>"$LOG_FILE" 2>&1
}

log() {
  ((LOG_ENABLED)) || return 0
  printf '[%s] %s
' "$(date '+%F %T')" "$*"
}
ROFI_THEME="$HOME/.config/rofi/utility.rasi"
TS_CREATE="$HOME/.local/bin/ts-create.sh"

notify() {
  command -v notify-send >/dev/null 2>&1 && notify-send "Recent Dirs" "$1" >/dev/null 2>&1 || true
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    notify "Missing command: $1"
    exit 1
  }
}

choose_mode() {
  printf 'Kitty\nNeovim\nThunar\n' |
    rofi -dmenu -i \
      -p 'Open with' \
      -theme "$ROFI_THEME" \
      -theme-str 'window { padding: 35% 40%; }'
}

build_display_list() {
  [[ -f "$RECENT_DIR_FILE" ]] || return 1
  tac "$RECENT_DIR_FILE" | awk -v home="$HOME" '{ if(index($0,home)==1) print "~" substr($0,length(home)+1); else print $0 }'
}

calc_width() {
  awk '
    { if(length($0)>max) max=length($0) }
    END {
      w=(max+6)*11;
      if(w<500) w=500;
      if(w>1600) w=1600;
      print w;
    }'
}

choose_directory() {
  [[ -f "$RECENT_DIR_FILE" ]] || {
    notify "No recent directories found."
    exit 1
  }

  local list width choice
  list="$(build_display_list)"
  [[ -n "$list" ]] || exit 0

  width="$(printf '%s\n' "$list" | calc_width)"

  choice=$(printf '%s\n' "$list" | rofi -dmenu -i \
    -p 'Select Directory' \
    -theme "$ROFI_THEME" \
    -theme-str "window { width: ${width}px; padding: 35% 30%; }")

  [[ -n "$choice" ]] || exit 0
  printf '%s\n' "${choice/#\~/$HOME}"
}

promote_recent_dir() {
  local target="$1" tmp
  tmp="$(mktemp)"
  awk -v t="$target" '
    { lines[NR]=$0 }
    END {
      for(i=1;i<=NR;i++){
        if(lines[i]==t){
          if(i>1){x=lines[i-1]; lines[i-1]=lines[i]; lines[i]=x}
          break
        }
      }
      for(i=1;i<=NR;i++) print lines[i]
    }' "$RECENT_DIR_FILE" >"$tmp"
  mv "$tmp" "$RECENT_DIR_FILE"
}

open_directory() {
  local mode="$1" dir="$2"
  [[ -d "$dir" ]] || {
    notify "Invalid path: $dir"
    exit 1
  }

  promote_recent_dir "$dir"

  case "$mode" in
    Kitty)
      need_cmd kitty
      kitty -e "$TS_CREATE" "$dir" >/dev/null 2>&1 &
      disown
      ;;
    Neovim)
      need_cmd kitty
      kitty -e "$TS_CREATE" "$dir" "nvim ." >/dev/null 2>&1 &
      disown
      ;;
    Thunar)
      need_cmd thunar
      thunar "$dir" >/dev/null 2>&1 &
      disown
      ;;
    *)
      notify "Unknown mode: $mode"
      exit 1
      ;;
  esac
}

parse_args() {
  while (($#)); do
    case "$1" in
      --log) LOG_ENABLED=1 ;;
      -h | --help)
        usage
        exit 0
        ;;
      *) ;;
    esac
    shift
  done
}

main() {
  parse_args "$@"
  log_init
  log "Starting recent_dir_v2"
  need_cmd rofi

  local mode dir
  mode="$(choose_mode)"
  [[ -n "$mode" ]] || exit 0

  dir="$(choose_directory)"
  [[ -n "$dir" ]] || exit 0

  notify "Opening: $dir"
  open_directory "$mode" "$dir"
}

main "$@"
