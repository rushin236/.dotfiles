#!/bin/bash

MONITOR_STATE="$HOME/.monitor_state.txt"

# Function to show desktop notification
show_message() {
	local message="$1"
	notify-send "Message" "${message}"
}

check_dependencies() {
	if ! command -v xrandr &>/dev/null; then
		show_message "Error: xrandr is not installed or not in PATH."
		exit 1
	fi
}

save_xrandr_output() {
	# Run xrandr and save output
	xrandr >"$MONITOR_STATE"
	show_message "xrandr output saved to: $MONITOR_STATE"
}

# Function to get max resolution and refresh rate
get_max_res_rate() {
	xrandr --query | sed -n "/^$1 connected/{n;p}" | awk '{print $1, $4}'
	# xrandr --query | grep -A 20 "^$1 connected" | grep -Eo "[0-9]+x[0-9]+\s+[0-9\.]+\*" | sort -r | head -n 1
}

get_primary_monitor() {
	xrandr --query | grep "primary" | awk '{print $1}'
}

get_focused_workspace() {
	# Use i3-msg to get workspaces and jq to filter the focused one
	focused_workspace=$(i3-msg -t get_workspaces | jq -r '.[] | select(.focused).name')

	# Print the focused workspace
	echo "Current focused workspace: $focused_workspace"
}

get_monitor_choice() {
	local monitor_info_raw primary_monitor options=""
	monitor_info_raw=$(xrandr | grep " connected")
	primary_monitor=$(echo "$monitor_info_raw" | grep " connected primary" | awk '{print $1}')

	while IFS= read -r info; do
		monitor=$(echo "$info" | awk '{print $1}')

		# Skip monitor if it's already the primary
		if [[ "$monitor" == "$primary_monitor" ]]; then
			continue
		fi

		# Check if the monitor is currently on (has resolution set)
		if echo "$info" | grep -q '[0-9]x[0-9]\+'; then
			options+="Toggle $monitor\n"
			options+="Primary $monitor\n"
		fi

		# Extend and Mirror options
		options+="Extend Right $monitor\n"
		options+="Extend Left $monitor\n"
		options+="Extend Up $monitor\n"
		options+="Extend Down $monitor\n"
		options+="Mirror $monitor to $primary_monitor"
	done <<<"$monitor_info_raw"

	# Show the menu and return the choice
	echo -e "$options" | rofi -dmenu -i -p "Monitor Control" -theme ~/.config/rofi/config.rasi
}

handle_monitor_choice() {
	local choice="$1"

	case "$choice" in
	Toggle*)
		selected_monitor=$(echo "$choice" | awk '{print $2}')
		# Check if the monitor is connected and active (has a resolution)
		if xrandr --query | grep "^$selected_monitor connected" | grep -q "[0-9]\+x[0-9]\++"; then
			xrandr --output "$selected_monitor" --off
			return 0
		else
			show_message "$selected_monitor is already turned off"
			return 1
		fi
		;;

	Primary*)
		selected_monitor=$(echo "$choice" | awk '{print $2}')
		res_rate=$(get_max_res_rate "$selected_monitor")
		max_res=$(echo "$res_rate" | awk '{print $1}')
		max_rate=$(echo "$res_rate" | awk '{print $2}')
		xrandr --output "$selected_monitor" --primary --mode "$max_res" --rate "$max_rate"
		return 0
		;;

	Extend*)
		direction=$(echo "$choice" | awk '{print $2}')
		selected_monitor=$(echo "$choice" | awk '{print $3}')
		other_monitor=$(get_primary_monitor)
		res_rate=$(get_max_res_rate "$selected_monitor")
		max_res=$(echo "$res_rate" | awk '{print $1}')
		max_rate=$(echo "$res_rate" | awk '{print $2}')

		case $direction in
		Right)
			xrandr --output "$selected_monitor" --mode "$max_res" --rate "$max_rate" --right-of "$other_monitor"
			;;
		Left)
			xrandr --output "$selected_monitor" --mode "$max_res" --rate "$max_rate" --left-of "$other_monitor"
			;;
		Up)
			xrandr --output "$selected_monitor" --mode "$max_res" --rate "$max_rate" --above "$other_monitor"
			;;
		Down)
			xrandr --output "$selected_monitor" --mode "$max_res" --rate "$max_rate" --below "$other_monitor"
			;;
		esac

		# Move workspace logic
		primary_ws=$(i3-msg -t get_workspaces | jq -r ".[] | select(.output==\"$other_monitor\").name")
		ws_count=$(echo "$primary_ws" | grep -c '.')

		if [ "$ws_count" -ge 2 ]; then
			ws_to_move=$(echo "$primary_ws" | sort | tail -n 1)
			i3-msg workspace "$ws_to_move"
			i3-msg move workspace to output "$selected_monitor"
		else
			max_ws=$(i3-msg -t get_workspaces | jq '.[].num' | sort -n | tail -n 1)
			i3-msg workspace "$max_ws"
			i3-msg move workspace to output "$selected_monitor"
		fi

		return 0
		;;

	Mirror*)
		selected_monitor=$(echo "$choice" | awk '{print $2}')
		primary_monitor=$(get_primary_monitor)

		res_rate_primary=$(get_max_res_rate "$primary_monitor")
		res_rate_selected=$(get_max_res_rate "$selected_monitor")

		max_res_primary=$(echo "$res_rate_primary" | awk '{print $1}')
		max_rate_primary=$(echo "$res_rate_primary" | awk '{print $2}')
		max_res_selected=$(echo "$res_rate_selected" | awk '{print $1}')
		max_rate_selected=$(echo "$res_rate_selected" | awk '{print $2}')

		xrandr --output "$primary_monitor" --mode "$max_res_primary" --rate "$max_rate_primary" --pos 0x0 \
			--output "$selected_monitor" --mode "$max_res_selected" --rate "$max_rate_selected" --pos 0x0

		return 0
		;;

	*)
		return 1
		;;
	esac
}

check_dependencies

option=$(get_monitor_choice)

if handle_monitor_choice "$option"; then
	i3-msg restart
	save_xrandr_output
fi

exit 0
