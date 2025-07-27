#!/bin/bash

MONITOR_STATE="$HOME/.monitor_state.txt"

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

main() {
	if [[ ! -f "$MONITOR_STATE" ]]; then
		save_xrandr_output
		exit 0
	fi

	# Turn off all connected monitors first
	for monitor in $(grep " connected" "$MONITOR_STATE" | awk '{print $1}'); do
		xrandr --output "$monitor" --off
	done

	while read -r line; do
		if [[ "$line" =~ ^([A-Z0-9-]+)\ connected.*([0-9]+x[0-9]+\+[0-9]+\+[0-9]+) ]]; then
			is_primary=0
			monitor=$(echo "$line" | awk '{print $1}')

			xrandr --output $monitor --off

			if [[ "$line" == *" primary "* ]]; then
				respos=$(echo "$line" | awk '{print $4}')
				is_primary=1
			else
				respos=$(echo "$line" | awk '{print $3}')
			fi

			resolution=$(echo "$respos" | cut -d'+' -f1)
			pos_x=$(echo "$respos" | cut -d'+' -f2)
			pos_y=$(echo "$respos" | cut -d'+' -f3)

			read -r next_line

			refresh=$(echo "$next_line" | grep -oP '[0-9.]+(?=\*)')

			cmd="xrandr --output $monitor --mode $resolution --pos ${pos_x}x${pos_y} --rate $refresh"

			if ((is_primary)); then
				cmd="$cmd --primary"
			fi

			$cmd

		fi
	done < <(grep -A1 " connected" "$MONITOR_STATE")
}

check_dependencies

main
