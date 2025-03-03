#!/bin/bash
options="Lock\nLogout\nReboot\nShutdown"
selected=$(echo -e "$options" | rofi -dmenu -p "Power Menu" -theme ~/.config/rofi/config.rasi)
case $selected in
    "Lock") ~/.config/i3/scripts/i3lock.sh ;;
    "Logout") i3-msg exit ;;
    "Reboot") systemctl reboot ;;
    "Shutdown") systemctl poweroff ;;
esac
