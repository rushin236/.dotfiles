#!/bin/bash

# LOGFILE="$HOME/dpms-watcher.log"
#
# log() {
# echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >>"$LOGFILE"
# }

log "=== DPMS watcher started ==="

xset dpms 0 0 720

while true; do
	# Check playerctl playback status
	playing=$(playerctl status 2>/dev/null)

	# Get current DPMS enabled/disabled status: "DPMS is Enabled" or "DPMS is Disabled"
	dpms_status=$(xset -q | grep "DPMS is" | awk '{print $3}')

	if [[ "$playing" == "Playing" ]]; then
		# If media is playing and DPMS is currently Enabled, disable DPMS
		if [[ "$dpms_status" == "Enabled" ]]; then
			# log "Media is playing — disabling DPMS"
			xset -dpms
		fi
	else
		# No media playing; if DPMS is Disabled, enable DPMS
		if [[ "$dpms_status" == "Disabled" ]]; then
			# log "No media playing — enabling DPMS"
			xset +dpms
		fi
	fi

	sleep 25
done
