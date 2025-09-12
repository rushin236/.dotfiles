#!/bin/bash

OUT="$HOME/.xrandr.conf"
>"$OUT"

XRANDR_CMD="xrandr"

while IFS= read -r line; do
	mon=$(echo "$line" | grep " connected" | awk '{print $1}')
	if [[ -n $mon ]]; then

		# Check if primary
		is_primary=false
		if [[ "$line" == *primary* ]]; then
			is_primary=true
		fi

		# Get resolution and position
		res_pos=$(echo "$line" | grep -o '[0-9]\+x[0-9]\++[0-9]\++[0-9]\+')

		if [[ -n $res_pos ]]; then
			# Read the next line (mode list)
			IFS= read -r next_line
			res=$(echo "$next_line" | awk '{print $1}')

			# Determine refresh rate
			if [[ "$next_line" == *" + "* ]]; then
				rate=$(echo "$next_line" | cut -d'+' -f2 | awk '{print $1}')
			else
				rate=$(echo "$next_line" | awk -v r="$res" '$1 == r {print $2}')
			fi
			rate=${rate//\*/}

			# Extract X and Y
			x_pos=$(echo "$res_pos" | cut -d'+' -f2)
			y_pos=$(echo "$res_pos" | cut -d'+' -f3)

			# Append monitor to xrandr command
			XRANDR_CMD+=" --output $mon --mode $res --rate $rate --pos ${x_pos}x${y_pos}"
			$is_primary && XRANDR_CMD+=" --primary"
		else
			# If disconnected or ignored, turn off
			XRANDR_CMD+=" --output $mon --off"
		fi
	fi
done < <(xrandr -q)

# Save to file
echo "$XRANDR_CMD" >"$OUT"

echo "Saved xrandr command to $OUT"
