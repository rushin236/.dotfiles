#!/bin/bash

# Force lock mode (when called with "lock" argument)
if [[ "$1" == "lock" ]]; then
	xset +dpms
	betterlockscreen -l blur --off 720
	exit 0
fi

# Default behavior: auto-lock only if no media players are active
for player in $(playerctl -l 2>/dev/null); do
	status=$(playerctl -p "$player" status 2>/dev/null)
	if [[ "$status" == "Playing" ]]; then
		echo "Media playing on $player, skipping auto-lock."
		exit 0
	fi
done

# No media is playing, proceed to lock
xset +dpms
betterlockscreen -l blur --off 720
exit 0
