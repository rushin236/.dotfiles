#!/bin/bash

# Kill all running Polybar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

if type "xrandr"; then
	# Get monitor info
	PRIMARY=$(xrandr --query | grep " connected primary" | awk '{print $1}')
	SECONDARIES=$(xrandr --query | grep " connected" | grep -v " primary" | awk '{print $1}')

	# Export primary monitor
	export PRIMARY_MONITOR=$PRIMARY

	# Launch primary bar (with systray)
	polybar primary &

	# Launch bars for all secondary monitors (without systray)
	for m in $SECONDARIES; do
		MONITOR=$m polybar secondary &
	done
else
	polybar --reload primary &
fi
