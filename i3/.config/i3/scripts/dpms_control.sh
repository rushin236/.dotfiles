#!/usr/bin/env bash
# dpms_control.sh - keep DPMS on when no media playing, disable DPMS while playing
# Designed to be started at i3 startup (exec --no-startup-id ...) or via systemd --user.

set -euo pipefail

show_message() {
    local message="$1"
    notify-send "Message" "${message}"
}

# ----- config -----
PIDFILE="/run/user/$UID/dpms_control.pid"
SLEEP_INTERVAL=15   # seconds between checks
# -------------------

# prevent duplicate instances using a pidfile
if [[ -f "$PIDFILE" ]]; then
    oldpid=$(cat "$PIDFILE" 2>/dev/null || show_message "")
    if [[ -n "$oldpid" ]] && kill -0 "$oldpid" 2>/dev/null; then
        show_message "[INFO] dpms_control already running (pid $oldpid). Exiting."
        exit 0
    else
        show_message "[WARN] Removing stale pidfile."
        rm -f "$PIDFILE"
    fi
fi

# write our pid
mkdir -p "$(dirname "$PIDFILE")"
echo $$ >"$PIDFILE"

cleanup() {
    show_message "[INFO] dpms_control: cleanup - re-enabling DPMS/screensaver and removing pidfile."
    # Re-enable DPMS and screensaver
    xset +dpms
    xset s on
    xset s default
    rm -f "$PIDFILE"
    exit 0
}
trap cleanup SIGTERM SIGINT EXIT

# Apply initial settings (each xset command separate)
xset s off
xset s noblank
xset s noexpose
xset s 0 0                 # no screensaver timeout
xset dpms 0 0 900          # standby/suspend/off in seconds (optional)

# show_message "[INFO] dpms_control started (pid $$). Checking player status every ${SLEEP_INTERVAL}s."

while true; do
    # check if any player reports "Playing"
    if playerctl -a status 2>/dev/null | grep -qi '^playing$'; then
        # if DPMS enabled, disable it while playing
        if xset q | awk '/DPMS is/ {print $3}' | grep -iq '^Enabled$' ; then
            # show_message "[INFO] Media playing — disabling DPMS."
            xset -dpms
            xset s off
        fi
    else
        # No media playing — ensure DPMS is enabled (so system can blank normally)
        if xset q | awk '/DPMS is/ {print $3}' | grep -iq '^Disabled$' ; then
            # show_message "[INFO] No media - enabling DPMS."
            xset +dpms
            # optionally re-enable screensaver (use default or specific)
            xset s on
        fi
    fi

    sleep "$SLEEP_INTERVAL"
done

