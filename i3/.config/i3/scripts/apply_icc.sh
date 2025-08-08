#!/bin/bash

# Function to show desktop notification
show_message() {
	local message="$1"
	notify-send "Message" "${message}"
}

# Path to ICC profile folder
ICC_DIR="$HOME/.dotfiles/i3/.config/i3/icc"

# Check if any .icc or .icm files exist
if ! find "$ICC_DIR" -maxdepth 1 \( -name '*.icc' -o -name '*.icm' \) | grep -q .; then
	show_message "No ICC profiles (.icc or .icm) found in $ICC_DIR"
	exit 0
fi

# Apply ICC profile to each connected monitor
xrandr --query | grep " connected" | while read -r line; do
	MONITOR_NAME=$(echo "$line" | awk '{print $1}')

	res_pos=$(echo "$line" | grep -o '[0-9]\+x[0-9]\++[0-9]\++[0-9]\+')

	if [[ -n $res_pos ]]; then
		ICC_PROFILE_ICC="$ICC_DIR/$MONITOR_NAME.icc"
		ICC_PROFILE_ICM="$ICC_DIR/$MONITOR_NAME.icm"

		MONITOR_NUMBER=$(dispwin -h 2>&1 | grep -F "$MONITOR_NAME" | awk '{print $1}')
		echo "$MONITOR_NUMBER"

		if [ -f "$ICC_PROFILE_ICC" ]; then
			dispwin -d "$MONITOR_NUMBER" "$ICC_PROFILE_ICC"
			# echo "$ICC_PROFILE_ICC"
			show_message "Applied ICC profile ($MONITOR_NAME.icc) for $MONITOR_NAME"
		elif [ -f "$ICC_PROFILE_ICM" ]; then
			dispwin -d "$MONITOR_NUMBER" "$ICC_PROFILE_ICM"
			# echo "$ICC_PROFILE_ICM"
			show_message "Applied ICC profile ($MONITOR_NAME.icm) for $MONITOR_NAME"
		else
			show_message "No ICC profile found for $MONITOR_NUMBER"
		fi
	fi
done

exit 0
