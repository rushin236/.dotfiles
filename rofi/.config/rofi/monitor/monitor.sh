#!/bin/bash

# Get connected monitors
monitors=$(xrandr --query | grep " connected" | awk '{print $1}')

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

# Get list of connected monitors and their state
mapfile -t monitor_info < <(xrandr | grep " connected")

# Get current primary monitor
primary_monitor=$(xrandr | grep " connected primary" | awk '{print $1}')

options=""

for info in "${monitor_info[@]}"; do
	monitor=$(echo "$info" | awk '{print $1}')

	# Skip monitor if it's already the primary
	if [[ "$monitor" == "$primary_monitor" ]]; then
		continue
	fi

	# Check if the monitor is currently on (has resolution set)
	if echo "$info" | grep -q '[0-9]x[0-9]\+'; then
		is_on="yes"
	else
		is_on="no"
	fi

	# Only show Toggle if monitor is currently active
	if [[ "$is_on" == "yes" ]]; then
		options+="Toggle $monitor\n"
		options+="Primary $monitor\n"
	fi

	# Extend options
	options+="Extend Right $monitor\n"
	options+="Extend Left $monitor\n"
	options+="Extend Up $monitor\n"
	options+="Extend Down $monitor\n"
	options+="Mirror $monitor to $primary_monitor\n"
done

# Show menu with rofi
choice=$(echo -e "$options" | rofi -dmenu -i -p "Monitor Control" -theme ~/.config/rofi/config.rasi)

# Execute based on choice
case "$choice" in
Toggle*)
	selected_monitor=$(echo "$choice" | awk '{print $2}')
	# Check if the monitor is connected and active (has a resolution)
	if xrandr --query | grep "^$selected_monitor connected" | grep -q "[0-9]\+x[0-9]\++"; then
		# If active, turn it off
		xrandr --output "$selected_monitor" --off
	else
		# If inactive but connected, print a message and exit gracefully
		rofi -e "$selected_monitor is already turned off"
		exit 0
	fi
	;;

Primary*)
	selected_monitor=$(echo "$choice" | awk '{print $2}')
	# echo $selected_monitor
	res_rate=$(get_max_res_rate "$selected_monitor")
	max_res=$(echo "$res_rate" | awk '{print $1}')
	max_rate=$(echo "$res_rate" | awk '{print $2}')
	# echo $res_rate
	xrandr --output "$selected_monitor" --primary --mode "$max_res" --rate "$max_rate"
	i3-msg restart
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

	# Get workspaces on primary monitor
	primary_ws=$(i3-msg -t get_workspaces | jq -r ".[] | select(.output==\"$other_monitor\").name")

	# Count workspaces on primary monitor
	ws_count=$(echo "$primary_ws" | grep -c '.')

	# If there are two or more workspaces on the primary monitor, move one to the extended monitor
	if [ "$ws_count" -ge 2 ]; then
		# Get the first workspace from the list
		ws_to_move=$(echo "$primary_ws" | sort | tail -n 1) # moves the last ws
		# ws_to_move=$(echo "$primary_ws" | sort | sed -n 2p) # moves the second ws

		# Move it to the new monitor
		i3-msg workspace "$ws_to_move"
		i3-msg move workspace to output "$selected_monitor"
	else
		# Get the maximum workspace number
		max_ws=$(i3-msg -t get_workspaces | jq '.[].num' | sort -n | tail -n 1)

		# Create and move new workspace to the selected monitor
		i3-msg workspace "$max_ws"
		i3-msg move workspace to output "$selected_monitor"
	fi

	# Restart i3 to apply changes
	i3-msg restart
	;;

Mirror*)
	primary_monitor=$(echo "$monitors" | awk '{print $1}')
	secondary_monitor=$(echo "$monitors" | awk '{print $2}')
	res_rate=$(get_max_res_rate "$primary_monitor")
	max_res=$(echo "$res_rate" | awk '{print $1}')
	max_rate=$(echo "$res_rate" | awk '{print $2}')
	xrandr --output "$primary_monitor" --mode "$max_res" --rate "$max_rate" --output "$secondary_monitor" --same-as "$primary_monitor"
	;;

*)
	echo "Invalid option"
	;;
esac
