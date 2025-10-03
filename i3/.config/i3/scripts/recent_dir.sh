#!/bin/bash

# === Config ===
RECENT_DIR_FILE="$HOME/.recent_dirs"
ROFI_THEME="-theme ~/.config/rofi/config.rasi"

show_message() {
	local message="$1"
	notify-send "Recent Dirs" "$message"
}

check_dependencies() {
	local missing=()

	for cmd in rofi notify-send alacritty nvim thunar; do
		if ! command -v "$cmd" &>/dev/null; then
			missing+=("$cmd")
		fi
	done

	if [ ${#missing[@]} -gt 0 ]; then
		show_message "
Some required tools are missing:

$(printf '  - %s\n' "${missing[@]}")

Install Instructions:
- Arch: sudo pacman -S <package>
- Debian/Ubuntu: sudo apt install <package>
"
		exit 1
	fi
}

choose_mode() {
    local options=("Alacritty" "Neovim" "Thunar")
    printf "%s\n" "${options[@]}" | rofi -dmenu -i -p "Open with" \
        $ROFI_THEME \
        -theme-str 'window { width: 15%; }'
}

choose_path() {
	[[ -f "$RECENT_DIR_FILE" ]] || {
		show_message "No recent directories found."
		exit 1
	}

	# Build menu: show basename with full path as map
	mapfile -t all_paths <"$RECENT_DIR_FILE"

	# Build associative map
	declare -A path_map
	menu_list=()

	# for full in "${all_paths[@]}"; do
	# 	short="$(basename "$full")"
	# 	# If short name already exists, disambiguate
	# 	while [[ -n "${path_map[$short]}" && "${path_map[$short]}" != "$full" ]]; do
	# 		short="$short/"
	# 	done
	# 	path_map["$short"]="$full"
	# 	menu_list+=("$short")
	# done

  HOME_DIR="/home/$USER"

	# Reverse array before showing in rofi
	reversed_menu=()
	# for ((idx = ${#menu_list[@]} - 1; idx >= 0; idx--)); do
	for ((idx = ${#all_paths[@]} - 1; idx >= 0; idx--)); do
    if [[ ${all_paths[idx]} == $HOME_DIR* ]]; then
      reversed_menu+=("~${all_paths[idx]#$HOME_DIR}")
    else
      reversed_menu+=("${all_paths[idx]}")
    fi	
  done

  local maxlen
  maxlen=$(printf "%s\n" "${reversed_menu[@]}" | awk '{ if (length>m) m=length } END { print m }')
  # add small padding
  local width=$(((maxlen + 2) * 10))

	choice=$(printf "%s\n" "${reversed_menu[@]}" \
    | rofi -dmenu -i -p "Select Directory" $ROFI_THEME -theme-str "window { width: ${width}px; }")

	if [[ -z "$choice" ]]; then
		exit 0
	fi

	# Resolve back to full path
	# full_path="${path_map[$choice]}"
  
	full_path="${choice/#\~/$HOME}"
	if [[ ! -d "$full_path" ]]; then
		show_message "Invalid path: $full_path"
		exit 1
	fi

	# Show full path via notify
	show_message "Opening: $full_path"

	# Return via echo (so caller can capture)
	echo "$full_path"
}

transpose_entry() {
	local file="$1"
	local entry="$2"

	# Read lines
	mapfile -t lines <"$file"

	for ((i = 0; i < ${#lines[@]}; i++)); do
		# Trim whitespace for comparison
		local current_line=$(echo "${lines[i]}" | xargs)
		local target_entry=$(echo "$entry" | xargs)

		if [[ "$current_line" == "$target_entry" ]]; then
			if [[ $i -gt 0 ]]; then
				# Swap with previous line
				tmp="${lines[i - 1]}"
				lines[i - 1]="${lines[i]}"
				lines[i]="$tmp"
			fi
			break
		fi
	done

	# Write back
	printf "%s\n" "${lines[@]}" >"$file"
}

open_path() {
	local mode="$1"
	local path="$2"

	if [[ ! -d "$path" ]]; then
		show_message "Invalid path: $path"
		exit 1
	fi

	# Apply transposition to the recent dir file
	transpose_entry "$RECENT_DIR_FILE" "$path"

	case "$mode" in
	"Alacritty") alacritty --working-directory "$path" & ;;
	"Neovim") alacritty -e nvim "$path" & ;;
	"Thunar") thunar "$path" & ;;
	*) show_message "Unknown mode: $mode" && exit 1 ;;
	esac
}

# === Main Execution ===
check_dependencies

mode=$(choose_mode)
[[ -z "$mode" ]] && exit 0

dir=$(choose_path)
[[ -z "$dir" ]] && exit 0

open_path "$mode" "$dir"
