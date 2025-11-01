#!/usr/bin/env bash

# ==========================
# Arch QEMU/KVM VM Manager
# ==========================
# Rofi + virsh + virt-viewer

# ---------------
# Configuration
# ---------------
ROFI_THEME="-theme ~/.config/rofi/config.rasi" # Adjust to your theme
VIRSH_URI="qemu:///system"                     # Use qemu:///session if needed

# ---------------
# Notifications
# ---------------
show_message() {
	local message="$1"
	notify-send "VM Manager" "${message}"
}

# ---------------
# Check if VM is running
# ---------------
vm_is_running() {
	local name="$1"
	virsh -c "$VIRSH_URI" domstate "$name" 2>/dev/null | grep -q running
}

# ---------------
# Main Menu
# ---------------
main_menu() {
	local options=(
		"1. Start VM"
		"2. Start VM from snapshot"
		"3. List running VMs"
		"4. Shutdown running VM"
		"5. Force Shutdown running VM"
		"6. Exit"
	)

	local choice
	choice=$(printf '%s\n' "${options[@]}" | rofi -dmenu -p "VM Manager" $ROFI_THEME)

	case "$choice" in
	"1. Start VM") start_vm ;;
	"2. Start VM from snapshot") start_vm_from_snapshot ;;
	"3. List running VMs") list_running_vms ;;
	"4. Shutdown running VM") shutdown_vm ;;
	"5. Force Shutdown running VM") force_shutdown_vm ;;
	"6. Exit") return 1 ;;
	*) return 1 ;;
	esac
}

# ---------------
# Start VM
# ---------------
start_vm() {
	local vms
	vms=$(virsh -c "$VIRSH_URI" list --all --name | grep -v "^$" | sort)

	if [ -z "$vms" ]; then
		show_message "No VMs found"
		return 1
	fi

	local chosen_vm
	chosen_vm=$(echo "$vms" | rofi -dmenu -p "Select VM to start" $ROFI_THEME)

	if [ -n "$chosen_vm" ]; then
		if ! vm_is_running "$chosen_vm"; then
			show_message "Starting $chosen_vm..."
			if ! virsh -c "$VIRSH_URI" start "$chosen_vm"; then
				show_message "Failed to start VM: $chosen_vm"
				return 1
			fi
			# Start virt-viewer in background
			virt-viewer -c "$VIRSH_URI" "$chosen_vm" &>/dev/null &

			sleep 1

			# Check if viewer started successfully
			if pgrep -f "virt-viewer.*$chosen_vm" >/dev/null; then
				return 0
			else
				show_message "Failed to open virt-viewer for: $chosen_vm"
				return 1
			fi
		else
			show_message "VM $chosen_vm is already running..."
			return 0
		fi
	else
		return 1
	fi
}

# ---------------
# Start VM from snapshot
# ---------------
start_vm_from_snapshot() {
	local vms
	vms=$(virsh -c "$VIRSH_URI" list --all --name | grep -v "^$" | sort)

	if [ -z "$vms" ]; then
		show_message "No VMs found"
		return 1
	fi

	local chosen_vm
	chosen_vm=$(echo "$vms" | rofi -dmenu -p "Select VM" $ROFI_THEME)

	if [ -z "$chosen_vm" ]; then
		return 1
	fi

	if vm_is_running "$chosen_vm"; then
		show_message "VM $chosen_vm is already running — please shut it down before reverting to snapshot."
		return 1
	fi

	local snapshots
	snapshots=$(virsh -c "$VIRSH_URI" snapshot-list "$chosen_vm" --name | grep -v "^$" | sort)

	if [ -z "$snapshots" ]; then
		show_message "No snapshots found for $chosen_vm"
		return 1
	fi

	local chosen_snapshot
	chosen_snapshot=$(echo "$snapshots" | rofi -dmenu -p "Select snapshot for $chosen_vm" $ROFI_THEME)

	if [ -n "$chosen_snapshot" ]; then
		show_message "Reverting $chosen_vm to snapshot $chosen_snapshot..."
		if ! virsh -c "$VIRSH_URI" snapshot-revert "$chosen_vm" "$chosen_snapshot"; then
			show_message "Failed to revert to snapshot."
			return 1
		fi

		virt-viewer -c "$VIRSH_URI" "$chosen_vm" &>/dev/null &

		sleep 1

		# Check if viewer started successfully
		if pgrep -f "virt-viewer.*$chosen_vm" >/dev/null; then
			return 0
		else
			show_message "Failed to open virt-viewer for: $chosen_vm"
			return 1
		fi
	else
		return 1
	fi
}

# ---------------
# List running VMs
# ---------------
list_running_vms() {
	local running_vms
	running_vms=$(virsh -c "$VIRSH_URI" list --name | grep -v "^$")

	if [ -z "$running_vms" ]; then
		show_message "No running VMs"
	else
		show_message "Running VMs:\n$running_vms"
	fi

	return 1 # Prevent workspace switch
}

# ---------------
# Shutdown running VM
# ---------------
shutdown_vm() {
	local running_vms
	running_vms=$(virsh -c "$VIRSH_URI" list --name | grep -v "^$")

	if [ -z "$running_vms" ]; then
		show_message "No running VMs to shutdown"
		return 1
	fi

	local chosen_vm
	chosen_vm=$(echo "$running_vms" | rofi -dmenu -p "Select VM to shutdown" $ROFI_THEME)

	if [ -n "$chosen_vm" ]; then
		show_message "Attempting graceful shutdown of $chosen_vm..."
		virsh -c "$VIRSH_URI" shutdown "$chosen_vm"

		# Wait max 10 seconds
		for i in {1..10}; do
			: "$i"
			sleep 1
			if ! virsh -c "$VIRSH_URI" domstate "$chosen_vm" | grep -q running; then
				show_message "$chosen_vm shut down successfully"
				return 1
			fi
		done

		# If still running, warn user
		show_message "$chosen_vm did not respond to graceful shutdown. May need to force shutdown."

		# Suggest enabling proper guest-side support
		show_message "Tip: Install 'acpid' (Linux) or 'qemu-guest-agent' in your VM for reliable shutdown."

		# If still running, ask user to force shutdown
		# local confirm_force
		# confirm_force=$(printf "Yes\nNo" | rofi -dmenu -p "$chosen_vm is still running — force shutdown?" $ROFI_THEME)

		# if [ "$confirm_force" == "Yes" ]; then
		if virsh -c "$VIRSH_URI" destroy "$chosen_vm"; then
			show_message "Forcing shutdown of $chosen_vm..."
			# virsh -c "$VIRSH_URI" destroy "$chosen_vm"
		# else
		# 	show_message "Shutdown aborted – VM is still running."
		fi
		return 1
	else
		return 1
	fi
}

# ---------------
# Force Shutdown running VM
# ---------------
force_shutdown_vm() {
	local running_vms
	running_vms=$(virsh -c "$VIRSH_URI" list --name | grep -v "^$")

	if [ -z "$running_vms" ]; then
		show_message "No running VMs to force stop"
		return 1
	fi

	local chosen_vm
	chosen_vm=$(echo "$running_vms" | rofi -dmenu -p "Select VM to force shutdown" $ROFI_THEME)

	if [ -n "$chosen_vm" ]; then
		# Confirm with user
		# local confirm
		# confirm=$(printf "Yes\nNo" | rofi -dmenu -p "Really force shutdown $chosen_vm?" $ROFI_THEME)

		# if [ "$confirm" == "Yes" ]; then
		if virsh -c "$VIRSH_URI" destroy "$chosen_vm"; then
			# virsh -c "$VIRSH_URI" destroy "$chosen_vm"
			show_message "$chosen_vm has been forcefully shut down."
		# else
		# 	show_message "Force shutdown canceled."
		fi
		return 1
	else
		return 1
	fi
}

# ---------------
# Dependency check
# ---------------
check_dependencies() {
	local missing=()

	command -v virsh >/dev/null || missing+=("libvirt-clients (virsh)")
	command -v virt-viewer >/dev/null || missing+=("virt-viewer")
	command -v rofi >/dev/null || missing+=("rofi (required for menu)")
	command -v notify-send >/dev/null || missing+=("libnotify (or compatible)")

	if [ ${#missing[@]} -gt 0 ]; then
		show_message "
Missing dependencies:
$(printf '  - %s\n' "${missing[@]}")

Install them via pacman:
sudo pacman -S libvirt virt-viewer rofi libnotify
"
		exit 0
	fi
}

# Run checks and launch menu
check_dependencies

main_menu
result=$?

# Only move to workspace 4 if a VM was launched successfully
if [ "$result" -eq 0 ]; then
	i3-msg "workspace number 4"
fi

exit $result
