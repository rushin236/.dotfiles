#!/bin/bash

# Kill all running Polybar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

if type "xrandr" >/dev/null 2>&1; then
	# Get primary monitor
	PRIMARY=$(xrandr --query | grep " connected primary" | awk '{print $1}')
	export PRIMARY_MONITOR=$PRIMARY

	# Get all connected monitor lines
	MONITOR_LINES=$(xrandr --query | grep " connected")

	# Get primary monitor position
	PRIMARY_POS=$(echo "$MONITOR_LINES" | grep "^$PRIMARY" | grep -oE '[0-9]+x[0-9]+\+[0-9]+\+[0-9]+')
	echo $PRIMARY_POS

	SECONDARIES=()

	while IFS= read -r line; do
		MON=$(echo "$line" | awk '{print $1}')
		[[ "$MON" == "$PRIMARY" ]] && continue

		MON_POS=$(echo "$line" | grep -oE '[0-9]+x[0-9]+\+[0-9]+\+[0-9]+')
		echo $MON_POS

		# If position differs from primary, include it as secondary
		if [[ "$MON_POS" != "$PRIMARY_POS" ]]; then
			SECONDARIES+=("$MON")
			echo "done"
		fi
		echo $SECONDARIES
	done <<<"$MONITOR_LINES"

	# Launch polybar on primary (with systray)
	polybar primary &

	# Launch polybar on non-mirrored secondary monitors (only if any exist)
	if [ "${#SECONDARIES[@]}" -gt 0 ]; then
		for m in "${SECONDARIES[@]}"; do
			MONITOR=$m polybar secondary &
		done
	fi
else
	polybar --reload primary &
fi
