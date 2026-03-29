#!/usr/bin/env bash
set -euo pipefail

# ╔══════════════════════════════════════════════════════╗
# ║  Fast TTY WM Launcher — SwayFX / Hyprland / Niri / i3║
# ║  Clean session startup from TTY, no DM required.     ║
# ╚══════════════════════════════════════════════════════╝

# --- Config ---
NVIDIA_GPU=true   # set to false if not using NVIDIA

UID_CACHE="$(id -u)"
RUNTIME_DIR_DEFAULT="/run/user/$UID_CACHE"
HAS_SYSTEMCTL=false
command -v systemctl >/dev/null 2>&1 && HAS_SYSTEMCTL=true

SESSION_VARS=(
    WAYLAND_DISPLAY DISPLAY XAUTHORITY
    XDG_SESSION_TYPE XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP DESKTOP_SESSION
    GDK_BACKEND QT_QPA_PLATFORM SDL_VIDEODRIVER CLUTTER_BACKEND
    MOZ_ENABLE_WAYLAND MOZ_DBUS_REMOTE
    QT_WAYLAND_DISABLE_WINDOWDECORATION
    ELECTRON_OZONE_PLATFORM_HINT
    QT_AUTO_SCREEN_SCALE_FACTOR
    GBM_BACKEND __GLX_VENDOR_LIBRARY_NAME LIBVA_DRIVER_NAME
    WLR_NO_HARDWARE_CURSORS WLR_RENDERER
    __NV_PRIME_RENDER_OFFLOAD __VK_LAYER_NV_optimus
    NIRI_SOCKET
    # DBUS_SESSION_BUS_ADDRESS
)

usage() {
    echo "Usage: $(basename "$0") {swayfx|hyprland|niri|i3}"
    exit 1
}

clean_env() {
    unset "${SESSION_VARS[@]}" 2>/dev/null || true
}

clean_systemd_env() {
    $HAS_SYSTEMCTL || return 0
    systemctl --user unset-environment "${SESSION_VARS[@]}" 2>/dev/null || true
}

ensure_runtime_dir() {
    export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-$RUNTIME_DIR_DEFAULT}"

    if [[ ! -d "$XDG_RUNTIME_DIR" ]]; then
        echo "FATAL: XDG_RUNTIME_DIR ($XDG_RUNTIME_DIR) doesn't exist."
        echo "Check that pam_systemd (or elogind) is set up correctly."
        exit 1
    fi
}

kill_portals() {
    pkill -u "$UID_CACHE" -x xdg-desktop-portal          2>/dev/null || true
    pkill -u "$UID_CACHE" -x xdg-desktop-portal-hyprland 2>/dev/null || true
    pkill -u "$UID_CACHE" -x xdg-desktop-portal-wlr      2>/dev/null || true
    pkill -u "$UID_CACHE" -x xdg-desktop-portal-gtk      2>/dev/null || true
    pkill -u "$UID_CACHE" -x xdg-desktop-portal-gnome    2>/dev/null || true
}

clean_runtime_artifacts() {
    local runtime_dir="${XDG_RUNTIME_DIR:-$RUNTIME_DIR_DEFAULT}"

    if ! pgrep -u "$UID_CACHE" -x sway >/dev/null 2>&1 &&
    ! pgrep -u "$UID_CACHE" -x Hyprland >/dev/null 2>&1 &&
    ! pgrep -u "$UID_CACHE" -x niri >/dev/null 2>&1; then
        rm -f "${runtime_dir}"/wayland-* 2>/dev/null || true
        rm -rf "${runtime_dir}"/hypr     2>/dev/null || true
        rm -f "${runtime_dir}"/niri-*    2>/dev/null || true
    fi

    if ! pgrep -u "$UID_CACHE" -x Xorg >/dev/null 2>&1 &&
    ! pgrep -u "$UID_CACHE" -x X    >/dev/null 2>&1; then
        rm -f /tmp/.X*-lock /tmp/.X11-unix/X* 2>/dev/null || true
    fi
}

set_nvidia_wayland() {
    export GBM_BACKEND=nvidia-drm
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export LIBVA_DRIVER_NAME=nvidia
    export WLR_NO_HARDWARE_CURSORS=1
}

set_nvidia_x11() {
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
}

set_wayland_common() {
    export XDG_SESSION_TYPE=wayland
    export GDK_BACKEND=wayland,x11
    export QT_QPA_PLATFORM="wayland;xcb"
    export SDL_VIDEODRIVER=wayland
    export CLUTTER_BACKEND=wayland
    export MOZ_ENABLE_WAYLAND=1
    export ELECTRON_OZONE_PLATFORM_HINT=auto
    export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
}

setup_swayfx() {
    set_wayland_common
    export XDG_CURRENT_DESKTOP=sway
    export XDG_SESSION_DESKTOP=sway
    export DESKTOP_SESSION=sway
    [[ "$NVIDIA_GPU" == true ]] && set_nvidia_wayland
}

setup_hyprland() {
    set_wayland_common
    export XDG_CURRENT_DESKTOP=Hyprland
    export XDG_SESSION_DESKTOP=Hyprland
    export DESKTOP_SESSION=Hyprland

    if [[ "$NVIDIA_GPU" == true ]]; then
        set_nvidia_wayland
        export WLR_RENDERER=vulkan
    fi
}

setup_niri() {
    set_wayland_common
    export XDG_CURRENT_DESKTOP=niri
    export XDG_SESSION_DESKTOP=niri
    export DESKTOP_SESSION=niri

    if [[ "$NVIDIA_GPU" == true ]]; then
        set_nvidia_wayland
    fi
}

setup_i3() {
    export XDG_SESSION_TYPE=x11
    export XDG_CURRENT_DESKTOP=i3
    export XDG_SESSION_DESKTOP=i3
    export DESKTOP_SESSION=i3
    export GDK_BACKEND=x11
    export QT_QPA_PLATFORM=xcb
    export SDL_VIDEODRIVER=x11
    [[ "$NVIDIA_GPU" == true ]] && set_nvidia_x11
}

run_session() {
    if [[ -n "${DBUS_SESSION_BUS_ADDRESS:-}" ]]; then
        exec "$@"
    else
        exec dbus-run-session "$@"
    fi
}

launch_wm() {
    local wm="${1:-}"
    [[ -n "$wm" ]] || usage

    # Save before cleaning
    local saved_dbus="${DBUS_SESSION_BUS_ADDRESS:-}"

    clean_env
    ensure_runtime_dir
    clean_systemd_env

    # Restore
    if [[ -n "$saved_dbus" ]]; then
        export DBUS_SESSION_BUS_ADDRESS="$saved_dbus"
    fi


    case "$wm" in
        swayfx)
            kill_portals
            clean_runtime_artifacts
            setup_swayfx
            run_session sway --unsupported-gpu
            ;;
        hyprland)
            kill_portals
            clean_runtime_artifacts
            setup_hyprland
            run_session start-hyprland
            ;;
        niri)
            kill_portals
            clean_runtime_artifacts
            setup_niri
            run_session niri
            ;;
        i3)
            clean_runtime_artifacts
            setup_i3
            local vt="${XDG_VTNR:-1}"
            run_session startx "$HOME/.xinitrc" -- ":${vt}" "vt${vt}"
            ;;
        *)
            echo "Unknown WM: $wm"
            usage
            ;;
    esac
}

launch_wm "${1:-}"
