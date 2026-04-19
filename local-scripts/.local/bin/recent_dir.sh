#!/usr/bin/env bash

set -euo pipefail

# --------------------------------------------------
# PATH
# --------------------------------------------------
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

# --------------------------------------------------
# CONFIG
# --------------------------------------------------
RECENT_DIR_FILE="$HOME/.recent_dirs"
ROFI_THEME=(-theme "$HOME/.config/rofi/utility.rasi")

# --------------------------------------------------
# HELPERS
# --------------------------------------------------

notify() {
  notify-send "Recent Dirs" "$1" >/dev/null 2>&1
}

require_commands() {
  local missing=()

  for cmd in rofi kitty nvim thunar; do
    command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
  done

  if ((${#missing[@]} > 0)); then
    notify "Missing commands: ${missing[*]}"
    exit 1
  fi
}

# --------------------------------------------------
# MENU 1 : MODE SELECTION
# --------------------------------------------------

choose_mode() {
  printf "%s\n" "Kitty" "Neovim" "Thunar" |
    rofi -dmenu -i \
      -p "Open with" \
      "${ROFI_THEME[@]}" \
      -theme-str 'window { padding: 35% 40%; }'
}

# --------------------------------------------------
# MENU 2 : DIRECTORY SELECTION
# --------------------------------------------------

choose_directory() {
  [[ -f "$RECENT_DIR_FILE" ]] || {
    notify "No recent directories found."
    exit 1
  }

  mapfile -t dirs <"$RECENT_DIR_FILE"

  local home_dir="$HOME"
  local display_list=()

  # Reverse order (latest first)
  for ((i = ${#dirs[@]} - 1; i >= 0; i--)); do
    if [[ ${dirs[i]} == "$home_dir"* ]]; then
      display_list+=("~${dirs[i]#$home_dir}")
    else
      display_list+=("${dirs[i]}")
    fi
  done

  # -----------------------------------
  # Find longest visible entry
  # -----------------------------------
  local max_len=0
  local item

  for item in "${display_list[@]}"; do
    ((${#item} > max_len)) && max_len=${#item}
  done

  # Add padding
  ((max_len += 6))

  # Convert chars -> pixels
  local width=$((max_len * 11))

  # Optional limits
  ((width < 500)) && width=500
  ((width > 1600)) && width=1600

  local choice
  choice=$(
    printf "%s\n" "${display_list[@]}" |
      rofi -dmenu -i \
        -p "Select Directory" \
        "${ROFI_THEME[@]}" \
        -theme-str "
                window {
                    width: ${width}px;
                    padding: 35% 30%;
                }
            "
  )

  [[ -z "$choice" ]] && exit 0

  echo "${choice/#\~/$HOME}"
}

# --------------------------------------------------
# MOVE SELECTED ENTRY UP BY ONE
# --------------------------------------------------

promote_recent_dir() {
  local target="$1"

  mapfile -t lines <"$RECENT_DIR_FILE"

  for ((i = 0; i < ${#lines[@]}; i++)); do
    if [[ "${lines[i]}" == "$target" ]]; then

      if ((i > 0)); then
        local temp="${lines[i - 1]}"
        lines[i - 1]="${lines[i]}"
        lines[i]="$temp"
      fi

      break
    fi
  done

  printf "%s\n" "${lines[@]}" >"$RECENT_DIR_FILE"
}

# --------------------------------------------------
# OPEN DIRECTORY
# --------------------------------------------------

open_directory() {
  local mode="$1"
  local dir="$2"

  [[ -d "$dir" ]] || {
    notify "Invalid path: $dir"
    exit 1
  }

  promote_recent_dir "$dir"

  case "$mode" in
    Kitty)
      kitty -e ~/.local/bin/ts-create.sh "$dir" &
      ;;

    Neovim)
      kitty -e ~/.local/bin/ts-create.sh "$dir" "nvim ." &
      ;;

    Thunar)
      thunar "$dir" &
      ;;

    *)
      notify "Unknown mode: $mode"
      exit 1
      ;;
  esac
}

# --------------------------------------------------
# MAIN
# --------------------------------------------------

main() {
  require_commands

  local mode
  mode=$(choose_mode)

  [[ -z "$mode" ]] && exit 0

  local dir
  dir=$(choose_directory)

  [[ -z "$dir" ]] && exit 0

  notify "Opening: $dir"

  open_directory "$mode" "$dir"
}

main
