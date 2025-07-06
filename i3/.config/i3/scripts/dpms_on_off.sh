#!/bin/bash

# LOGFILE="$HOME/dpms-watcher.log"
#
# log() {
# 	echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >>"$LOGFILE"
# }

log "=== DPMS watcher started ==="

while true; do
	# Check playerctl playback status
	playing=$(playerctl status 2>/dev/null)

	if [[ "$playing" == "Playing" ]]; then
		# log "Media is playing — disabling DPMS"
		xset -dpms
	else
		# log "No media playing — enabling DPMS"
		xset +dpms
	fi

	sleep 30
done
