#!/bin/bash

status=$(playerctl -p "$player" status 2>/dev/null)
dpms_status=$(xset -q | grep "DPMS is" | awk '{print $3}')

if [[ "$1" == "lock" ]]; then
	# Lock the screen with betterlockscreen (blur effect, off timeout 600s)
	if [[ "$dpms_status" == "Disabled" ]]; then
		xset +dpms
	fi
	betterlockscreen -l blur --off 720
	exit 0
fi

# Default behavior: only lock if no media players are playing
for player in $(playerctl -l 2>/dev/null); do
	if [[ "$status" == "Playing" ]]; then
		# Disable DPMS while media is playing to prevent screen off
		if [[ "$dpms_status" == "Enabled" ]]; then
			xset -dpms
		fi
		exit 0
	fi
done

# No media is playing, enable DPMS again and lock
if [[ "$dpms_status" == "Disabled" ]]; then
	xset +dpms
fi
betterlockscreen -l blur --off 720
exit 0
