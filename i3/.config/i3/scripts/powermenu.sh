#!/bin/bash

options="Lock\nLogout\nReboot\nShutdown"
selected=$(echo -e "$options" | rofi -dmenu -i -p "Power Menu" -theme ~/.config/rofi/config.rasi)
case $selected in
"Lock") betterlockscreen -l blur ;;
"Logout") i3-msg exit ;;
"Reboot") systemctl reboot ;;
"Shutdown") systemctl poweroff ;;
esac
