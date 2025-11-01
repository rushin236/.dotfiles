#!/usr/bin/env bash

# Configuration
ROFI_THEME="-theme ~/.config/rofi/config.rasi" # Adjust to your theme

show_message() {
	local message="$1"
	notify-send "Message" "${message}"
}

lm_studio_visible() {
	wmctrl -lx | awk '{print $3}' | grep -x "lm"
}

launch_lm_studio() {
	if pgrep -x "lm-studio" >/dev/null; then
		if lm_studio_visible; then
			notify-send "LM Studio is running and visible"
		else
			notify-send "Starting LM Studio UI again"
			"$HOME/.local/bin/lm-studio" &
		fi
	else
		notify-send "Launching LM Studio in workspace 3..."
		"$HOME/.local/bin/lm-studio" &
	fi
}

unload_all_models() {
	output=$("$HOME/.lmstudio/bin/lms" unload --all 2>&1)
	show_message "$output"
}

main_menu() {
	local options=(
		"1. Start LM Studio"
		"2. Unload all models"
		"3. Exit"
	)

	local choice
	choice=$(printf '%s\n' "${options[@]}" | rofi -dmenu -p "LM Studio Manager" $ROFI_THEME)

	case $choice in
	"1. Start LM Studio")
		launch_lm_studio
		exit 0
		;;
	"2. Unload all models")
		unload_all_models
		exit 1
		;;
	"3. Exit")
		exit 1
		;;
	*)
		exit 1
		;;
	esac
}

# Check for required dependencies for LM Studio and LMS CLI
check_dependencies() {
	local missing=()

	# Check for LM Studio binary
	if [ ! -x "$HOME/.local/bin/lm-studio" ] && ! command -v lm-studio &>/dev/null; then
		missing+=("lm-studio (GUI app)")
	fi

	# Check for LMS CLI
	if [ ! -x "$HOME/.lmstudio/bin/lms" ] && ! command -v lms &>/dev/null; then
		missing+=("lms CLI")
	fi

	# Check for wmctrl (used for WM_CLASS and workspace visibility)
	if ! command -v wmctrl &>/dev/null; then
		missing+=("wmctrl (used for window detection)")
	fi

	# If any dependencies are missing
	if [ ${#missing[@]} -gt 0 ]; then
		show_message "
    Some required tools are not installed
    Missing required tools/packages:
    $(printf '  - %s\n' "${missing[@]}")

    Install Instructions:
    - Arch Linux: sudo pacman -S <package>
    - Debian/Ubuntu: sudo apt install <package>

    LM Studio Guide: https://lmstudio.ai/docs
    "
		exit 1
	fi
}

check_dependencies

main_menu
