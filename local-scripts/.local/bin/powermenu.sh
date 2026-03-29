#!/usr/bin/env bash

# 1. Define and show the menu
options="Lock\nLogout\nReboot\nShutdown"
selected=$(echo -e "$options" | rofi -dmenu -i -p "Power Menu" -theme ~/.config/rofi/utility.rasi -theme-str 'window { width: 15%; }')

# 2. Grab the current Desktop/WM directly and make it lowercase
WM="${XDG_CURRENT_DESKTOP,,}"

# 3. Execute the appropriate command
case $selected in
    "Lock")
        case "$WM" in
            niri)     swaylock ;;
            hyprland) hyprlock ;;
            sway)     hyprlock ;;
            i3)       betterlockscreen -l blur ;;
        esac
        ;;
    "Logout")
        case "$WM" in
            niri)     niri msg action quit ;;
            hyprland) hyprctl dispatch exit ;;
            sway)     swaymsg exit ;;
            i3)       i3-msg exit ;;
        esac
        ;;
    "Reboot")
        systemctl reboot
        ;;
    "Shutdown")
        systemctl poweroff
        ;;
esac
