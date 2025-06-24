#!/bin/bash

# Check only browser media players
for player in $(playerctl -l 2>/dev/null); do
	if playerctl -p "$player" status 2>/dev/null | grep -q "Playing"; then
		# Any player is actively playing, skip locking
		exit 0
	fi
done

betterlockscreen -l blur --off 960
