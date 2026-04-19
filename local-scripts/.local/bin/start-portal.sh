#!/bin/bash

# ~/local-scripts/start-portal.sh
sleep 1
dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP="$1" XDG_SESSION_TYPE=wayland
systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
