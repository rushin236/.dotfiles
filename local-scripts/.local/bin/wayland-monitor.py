#!/usr/bin/env python3

import argparse
import json
import logging
import os
import shutil
import subprocess
import sys
from pathlib import Path


# --- 1. Logging Setup ---
def setup_logging():
    state_dir = Path.home() / ".local" / "state" / "wayland_monitor"
    state_dir.mkdir(parents=True, exist_ok=True)
    log_file = state_dir / "monitor.log"

    logging.basicConfig(
        filename=log_file,
        level=logging.INFO,
        format="%(asctime)s - %(levelname)s - %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
    )

    console = logging.StreamHandler()
    console.setLevel(logging.INFO)
    formatter = logging.Formatter("%(levelname)s: %(message)s")
    console.setFormatter(formatter)
    logging.getLogger("").addHandler(console)

    return log_file


def show_message(title: str, message: str):
    logging.info(f"NOTIFICATION [{title}]:\n{message}")
    if shutil.which("notify-send"):
        try:
            subprocess.run(["notify-send", title, message], check=False)
        except Exception as e:
            logging.error(f"Failed to send notification: {e}")
    else:
        logging.warning("notify-send not installed. Message only written to log.")


def add_local_bin_path():
    local_bin = os.path.expanduser("~/.local/bin")
    if os.path.exists(local_bin):
        if local_bin not in os.environ.get("PATH", "").split(os.pathsep):
            os.environ["PATH"] = f"{local_bin}{os.pathsep}{os.environ.get('PATH', '')}"
        logging.info(f"{local_bin} added to path!")


# --- 2. Environment & Dependency Checks ---
def check_session(is_test: bool):
    if is_test:
        return
    session_type = os.environ.get("XDG_SESSION_TYPE", "").lower()
    if session_type != "wayland":
        logging.warning(f"Aborted: Session is '{session_type}', expected 'wayland'.")
        print("Not a Wayland session. Exiting. Check logs.")
        sys.exit(0)


def check_dependencies(is_test: bool):
    if is_test:
        return
    required_cmds = ["wlr-randr", "rofi", "shikane"]
    missing = [cmd for cmd in required_cmds if shutil.which(cmd) is None]
    if missing:
        msg = "Missing tools:\n\n" + "\n".join(f"  - {cmd}" for cmd in missing)
        show_message("Monitor Script Error", msg)
        sys.exit(1)


# --- 3. Data Model ---
class Monitor:
    def __init__(self, data: dict):
        self.name = data.get("name", "Unknown")
        self.make = data.get("make", "Unknown")
        self.model = data.get("model", "Unknown")
        self.active = data.get("enabled", False)
        self.pos_x = data.get("x", 0)
        self.pos_y = data.get("y", 0)
        self.scale = float(data.get("scale", 1.0))

        transform = data.get("transform", "normal")
        self.orientation = {"90": 90, "180": 180, "270": 270}.get(transform, 0)

        self.max_width, self.max_height, self.max_refresh = 0, 0, 0.0
        modes = data.get("modes", [])
        if modes:
            modes.sort(
                key=lambda m: (
                    m.get("width", 0),
                    m.get("height", 0),
                    m.get("refresh", 0),
                ),
                reverse=True,
            )
            best = modes[0]
            self.max_width, self.max_height = best.get("width", 0), best.get(
                "height", 0
            )
            self.max_refresh = best.get("refresh", 0)

    @property
    def is_portrait(self) -> bool:
        return self.orientation in (90, 270)

    @property
    def effective_width(self) -> int:
        base = self.max_height if self.is_portrait else self.max_width
        return int(base / self.scale)

    @property
    def effective_height(self) -> int:
        base = self.max_width if self.is_portrait else self.max_height
        return int(base / self.scale)

    # @property
    # def icc_profile_path(self) -> str:
    #     """Returns the full path to the ICC profile if it exists, else empty string."""
    #     data_home = os.environ.get(
    #         "XDG_DATA_HOME", str(Path.home() / ".local" / "share")
    #     )
    #     icc_dir = Path(data_home) / "icc"
    #     icc_dir.mkdir(parents=True, exist_ok=True)
    #
    #     safe_name = f"{self.make}_{self.model}".replace(" ", "_")
    #     icc_file = icc_dir / f"{safe_name}.icc"
    #     icm_file = icc_dir / f"{safe_name}.icm"
    #
    #     if icc_file.exists():
    #         return str(icc_file)
    #     if icm_file.exists():
    #         return str(icm_file)
    #     return ""


# --- 4. State Fetching ---
def get_wlr_state(json_file: str = "") -> list[Monitor]:
    if json_file:
        with open(json_file, "r") as f:
            return [Monitor(m) for m in json.load(f)]
    res = subprocess.run(
        ["wlr-randr", "--json"], capture_output=True, text=True, check=True
    )
    return [Monitor(m) for m in json.loads(res.stdout)]


def get_focused_monitor_name(is_test: bool) -> str:
    if is_test:
        return ""
    desktop = os.environ.get("XDG_CURRENT_DESKTOP", "").lower()
    try:
        if "hyprland" in desktop:
            res = subprocess.run(
                ["hyprctl", "activeworkspace", "-j"], capture_output=True, text=True
            )
            return json.loads(res.stdout).get("monitor", "")
        elif "sway" in desktop:
            res = subprocess.run(
                ["swaymsg", "-t", "get_workspaces"], capture_output=True, text=True
            )
            return next(
                (
                    ws.get("output", "")
                    for ws in json.loads(res.stdout)
                    if ws.get("focused")
                ),
                "",
            )
        elif "niri" in desktop:
            res = subprocess.run(
                ["niri", "msg", "-j", "focused-output"], capture_output=True, text=True
            )
            return json.loads(res.stdout).get("name")

        return ""
    except Exception:
        return ""


# --- 5. Geometry Engine ---
def is_colliding(
    new_x: int, new_y: int, new_w: int, new_h: int, monitors: list, ignore_name: str
) -> bool:
    for m in monitors:
        if not m.active or m.name == ignore_name:
            continue
        if (
            new_x < m.pos_x + m.effective_width
            and new_x + new_w > m.pos_x
            and new_y < m.pos_y + m.effective_height
            and new_y + new_h > m.pos_y
        ):
            return True
    return False


def calculate_placements(
    target: Monitor, new_mon: Monitor, direction: str, monitors: list
) -> dict:
    valid = {}
    nw, nh = new_mon.effective_width, new_mon.effective_height
    if direction in ("right", "left"):
        fx = (
            target.pos_x + target.effective_width
            if direction == "right"
            else target.pos_x - nw
        )
        if target.effective_height == nh:
            if not is_colliding(fx, target.pos_y, nw, nh, monitors, new_mon.name):
                valid["Aligned"] = (fx, target.pos_y)
        else:
            snaps = {
                "Top": target.pos_y,
                "Bottom": target.pos_y + target.effective_height - nh,
                "Center": target.pos_y + (target.effective_height - nh) // 2,
            }
            for k, v in snaps.items():
                if not is_colliding(fx, v, nw, nh, monitors, new_mon.name):
                    valid[k] = (fx, v)
    elif direction in ("up", "down"):
        fy = (
            target.pos_y - nh
            if direction == "up"
            else target.pos_y + target.effective_height
        )
        if target.effective_width == nw:
            if not is_colliding(target.pos_x, fy, nw, nh, monitors, new_mon.name):
                valid["Aligned"] = (target.pos_x, fy)
        else:
            snaps = {
                "Left": target.pos_x,
                "Right": target.pos_x + target.effective_width - nw,
                "Center": target.pos_x + (target.effective_width - nw) // 2,
            }
            for k, v in snaps.items():
                if not is_colliding(v, fy, nw, nh, monitors, new_mon.name):
                    valid[k] = (v, fy)
    return valid


# --- 6. Config Writers ---
def write_configs(monitors: list, is_test: bool):
    h_path = (
        Path("./test_monitors.conf")
        if is_test
        else Path.home() / ".config/hypr/monitors.conf"
    )
    k_path = (
        Path("./test_kanshi_config")
        if is_test
        else Path.home() / ".config/kanshi/config"
    )
    # Shikane usually looks for config.toml
    s_path = (
        Path("./test_shikane_config.toml")
        if is_test
        else Path.home() / ".config/shikane/config.toml"
    )

    h_path.parent.mkdir(parents=True, exist_ok=True)
    k_path.parent.mkdir(parents=True, exist_ok=True)
    s_path.parent.mkdir(parents=True, exist_ok=True)

    # --- 1. Hyprland Config ---
    with open(h_path, "w") as f:
        f.write("# Generated by monitor_control.py\n")
        for m in monitors:
            if m.active:
                rot = {0: "0", 90: "1", 180: "2", 270: "3"}.get(m.orientation, "0")
                rule = f"monitor={m.name},{m.max_width}x{m.max_height}@{m.max_refresh:.5f},{m.pos_x}x{m.pos_y},{m.scale},transform,{rot},vrr,2"
                f.write(f"{rule}\n")
            else:
                f.write(f"monitor={m.name},disable\n")

    # --- 2. Kanshi Config ---
    with open(k_path, "w") as f:
        f.write("# Generated by monitor_control.py\nprofile active_layout {\n")
        for m in monitors:
            if m.active:
                trans = "normal" if m.orientation == 0 else str(m.orientation)
                f.write(
                    f"    output {m.name} mode {m.max_width}x{m.max_height}@{m.max_refresh:.3f}Hz position {m.pos_x},{m.pos_y} scale {m.scale} transform {trans} adaptive_sync on\n"
                )
            else:
                f.write(f"    output {m.name} disable\n")
        f.write("}\n")

    # --- 3. Shikane Config (TOML) ---
    with open(s_path, "w") as f:
        f.write(
            '# Generated by monitor_control.py\n[[profile]]\nname = "active_layout"\n\n'
        )
        for m in monitors:
            f.write("  [[profile.output]]\n")
            f.write(f'  search = "{m.name}"\n')
            if m.active:
                trans = "normal" if m.orientation == 0 else str(m.orientation)
                # Shikane expects specific strings for adaptive_sync and scale as float
                f.write("  enable = true\n")
                f.write(
                    f'  mode = "{m.max_width}x{m.max_height}@{m.max_refresh:.3f}"\n'
                )
                f.write(f'  position = "{m.pos_x},{m.pos_y}"\n')
                f.write(f"  scale = {float(m.scale)}\n")
                f.write(f'  transform = "{trans}"\n')
                f.write("  adaptive_sync = true\n")
            else:
                f.write("  enable = false\n")
            f.write("\n")


# --- 7. UI & Flow ---
def show_rofi_menu(prompt: str, options: list[str]) -> str:
    if not options:
        return ""
    rofi_theme = "-theme ~/.config/rofi/utility.rasi"
    cmd = f"rofi -dmenu -i -p '{prompt}' {rofi_theme}"
    proc = subprocess.Popen(
        cmd, shell=True, stdin=subprocess.PIPE, stdout=subprocess.PIPE, text=True
    )
    stdout, _ = proc.communicate(input="\n".join(options))
    return stdout.strip()


def execute_choice(choice: str, focused_name: str, monitors: list, is_test: bool):
    parts = choice.split()
    focused_mon = next((m for m in monitors if m.name == focused_name), None)

    if choice.startswith("Toggle Off"):
        target = next((m for m in monitors if m.name == parts[2]), None)
        if target:
            target.active = False

        active_monitors = [m for m in monitors if m.active]
        if len(active_monitors) == 1:
            single = active_monitors[0]
            if single.pos_x != 0 or single.pos_y != 0:
                logging.info(f"Resetting single monitor {single.name} to 0,0")
                single.pos_x, single.pos_y = 0, 0

    elif choice.startswith("Mirror"):
        target = next((m for m in monitors if m.name == parts[1]), None)
        if target and focused_mon:
            rot_options = [
                "0 (Normal)",
                "90 (Portrait)",
                "180 (Inverted)",
                "270 (Portrait Flipped)",
            ]
            rot_choice = show_rofi_menu(f"Rotation for {target.name}", rot_options)
            if rot_choice:
                target.orientation = int(rot_choice.split()[0])

            target.pos_x, target.pos_y, target.active = (
                focused_mon.pos_x,
                focused_mon.pos_y,
                True,
            )

    elif choice.startswith("Extend"):
        target = next((m for m in monitors if m.name == parts[1]), None)
        direction = parts[2].lower()

        if target and focused_mon:
            rot_options = [
                "0 (Normal)",
                "90 (Portrait)",
                "180 (Inverted)",
                "270 (Portrait Flipped)",
            ]
            rot_choice = show_rofi_menu(f"Rotation for {target.name}", rot_options)
            if rot_choice:
                target.orientation = int(rot_choice.split()[0])

            target.active = True

            valid_opts = calculate_placements(focused_mon, target, direction, monitors)
            if not valid_opts:
                show_message("Error", "Area blocked by another monitor.")
                target.active = False
                return

            align_key = (
                "Aligned"
                if (len(valid_opts) == 1 and "Aligned" in valid_opts)
                else show_rofi_menu(
                    "Select Alignment", [f"{k} Aligned" for k in valid_opts.keys()]
                ).split()[0]
            )

            target.pos_x, target.pos_y = (
                valid_opts[align_key][0],
                valid_opts[align_key][1],
            )

    write_configs(monitors, is_test)
    if not is_test:
        desktop = os.environ.get("XDG_CURRENT_DESKTOP", "").lower()

        if "hyprland" in desktop:
            # OPTION A: Let Hyprland reload its own config
            # This is safer because Hyprland is 'picky' about external tools
            logging.info("Hyprland detected. Reloading monitors.conf natively.")
            # Hyprland usually picks up file changes automatically if 'source' is used,
            # but we can force a reload of the keyword to be sure.
            subprocess.run(["hyprctl", "reload"], check=False)
            show_message("Monitor Layout", "Hyprland layout updated via monitors.conf")

        else:
            # OPTION B: Use Shikane for other Wayland WMs (Sway, River, etc.)
            logging.info(f"Non-Hyprland desktop ({desktop}) detected. Using Shikane.")
            if shutil.which("shikane"):
                subprocess.run("pkill shikane; shikane &", shell=True, check=False)
                show_message("Monitor Layout", "Configuration applied via Shikane.")
            else:
                # Fallback: If shikane isn't running, try wlr-randr directly
                logging.warning(
                    "shikanectl not found, layout might not apply automatically."
                )


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--wlr-json", type=str, help="Testing JSON path")
    args = parser.parse_args()
    is_test = bool(args.wlr_json)
    setup_logging()
    add_local_bin_path()
    check_session(is_test)
    check_dependencies(is_test)

    monitors = get_wlr_state(args.wlr_json)
    focused = get_focused_monitor_name(is_test) or monitors[0].name

    options = []
    active = [m for m in monitors if m.active]
    inactive = [m for m in monitors if not m.active]

    for m in active:
        if m.name != focused:
            options += [f"Toggle Off {m.name}", f"Mirror {m.name} to {focused}"]
    for i in inactive:
        options += [
            f"Extend {i.name} {d} of {focused}" for d in ["Right", "Left", "Up", "Down"]
        ]
        options += [f"Mirror {i.name} to {focused}"]

    choice = show_rofi_menu("Display Settings", options)
    if choice:
        execute_choice(choice, focused, monitors, is_test)


if __name__ == "__main__":
    main()
