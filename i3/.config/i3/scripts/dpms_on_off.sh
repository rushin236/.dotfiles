#!/bin/bash

xset s off s noblank s noexpose
xset s 0 0
xset dpms 0 0 720

while true; do
	playing=$(playerctl status 2>/dev/null)

	dpms_status=$(xset -q | grep "DPMS is" | awk '{print $3}')

	if [[ "$playing" == "Playing" && "$dpms_status" == "Enabled" ]]; then
		xset -dpms
	else
		if [[ "$dpms_status" == "Disabled" ]]; then
			xset +dpms
		fi
	fi

	sleep 10
done

exit 0
