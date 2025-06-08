#!/bin/bash

show_message() {
	local message="$1"
	notify-send "Audio out Changed to" "${message}"
}

ROFI_THEME="-theme ~/.config/rofi/config.rasi" # Adjust to your theme

# Get sink lines (Sinks = audio outputs)
sink_lines=$(wpctl status | awk '/Sinks:/,/Sources:/' | sed '/Sources:/d' | grep '\]$')

# Prepare list for rofi
choices=$(echo "$sink_lines" | sed -E 's/^[^0-9]*([0-9]+)\.\s+(.*?)\s*\[vol:.*$/\1: \2/' | awk -F': ' '{print $2}')

# Prompt user with rofi, include the theme
chosen=$(echo "$choices" | rofi -dmenu $ROFI_THEME -p "Select audio output")

if [[ -n "$chosen" ]]; then
	sink_id=$(echo "$sink_lines" | sed -E 's/^[^0-9]*([0-9]+)\.\s+(.*?)\s*\[vol:.*$/\1: \2/' | grep "$chosen" | awk -F': ' '{print $1}')
	wpctl set-default "$sink_id"
	show_message "$chosen"
fi
