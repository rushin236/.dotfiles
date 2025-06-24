#!/bin/bash

# Configuration
ROFI_THEME="-theme ~/.config/rofi/config.rasi" # Adjust to your theme
VIRSH_URI="qemu:///system"                     # Change if using different connection

show_message() {
	local message="$1"
	notify-send "Message" "${message}"
}

main_menu() {
	local options=(
		"1. Start VM"
		"2. Start VM from snapshot"
		"3. List running VMs"
		"4. Shutdown running VM"
		"5. Exit"
	)

	local choice
	choice=$(printf '%s\n' "${options[@]}" | rofi -dmenu -p "VM Manager" $ROFI_THEME)

	case $choice in
	"1. Start VM")
		start_vm
		;;
	"2. Start VM from snapshot")
		start_vm_from_snapshot
		;;
	"3. List running VMs")
		list_running_vms
		;;
	"4. Shutdown running VM")
		shutdown_vm
		;;
	"5. Exit")
		exit 0
		;;
	*)
		exit 0
		;;
	esac
}

start_vm() {
	local vms
	vms=$(virsh -c "$VIRSH_URI" list --all --name | grep -v "^$" | sort)

	if [ -z "$vms" ]; then
		show_message "No VMs found"
		return 1 # Failure exit code
	fi

	local chosen_vm
	chosen_vm=$(echo "$vms" | rofi -dmenu -p "Select VM to start" $ROFI_THEME)

	if [ -n "$chosen_vm" ]; then
		show_message "Starting $chosen_vm..."
		if virt-viewer -c "$VIRSH_URI" -a "$chosen_vm" &>/dev/null & then
			return 0 # Success exit code
		else
			show_message "Failed to start $chosen_vm"
			return 1 # Failure exit code
		fi
	else
		return 1 # No VM selected (failure)
	fi
}

start_vm_from_snapshot() {
	local vms
	vms=$(virsh -c "$VIRSH_URI" list --all --name | grep -v "^$" | sort)

	if [ -z "$vms" ]; then
		show_message "No VMs found"
		return 1 # Explicit failure code
	fi

	local chosen_vm
	chosen_vm=$(echo "$vms" | rofi -dmenu -p "Select VM" $ROFI_THEME)

	if [ -z "$chosen_vm" ]; then
		return 1 # No VM selected
	fi

	local snapshots
	snapshots=$(virsh -c "$VIRSH_URI" snapshot-list "$chosen_vm" --name | grep -v "^$" | sort)

	if [ -z "$snapshots" ]; then
		show_message "No snapshots found for $chosen_vm"
		return 1 # No snapshots exist
	fi

	local chosen_snapshot
	chosen_snapshot=$(echo "$snapshots" | rofi -dmenu -p "Select snapshot for $chosen_vm" $ROFI_THEME)

	if [ -n "$chosen_snapshot" ]; then
		show_message "Starting $chosen_vm from snapshot $chosen_snapshot..."

		# Attempt snapshot revert and VM launch
		if virsh -c "$VIRSH_URI" snapshot-revert "$chosen_vm" "$chosen_snapshot" &&
			virt-viewer -c "$VIRSH_URI" -a "$chosen_vm" &>/dev/null & then
			return 0 # Success - both commands worked
		else
			show_message "Failed to start $chosen_vm from snapshot"
			return 1 # Either snapshot revert or virt-viewer failed
		fi
	else
		return 1 # No snapshot selected
	fi
}

list_running_vms() {
	local running_vms
	running_vms=$(virsh -c "$VIRSH_URI" list --name | grep -v "^$")

	if [ -z "$running_vms" ]; then
		show_message "No running VMs"
	else
		show_message "Running VMs:\n$running_vms"
	fi
	# Always return failure (non-zero) to prevent workspace switch
	return 1
}

shutdown_vm() {
	local running_vms
	running_vms=$(virsh -c "$VIRSH_URI" list --name | grep -v "^$")

	if [ -z "$running_vms" ]; then
		show_message "No running VMs to shutdown"
		return 1 # Explicit failure to prevent workspace switch
	fi

	local chosen_vm
	chosen_vm=$(echo "$running_vms" | rofi -dmenu -p "Select VM to shutdown" $ROFI_THEME)

	if [ -n "$chosen_vm" ]; then
		show_message "Shutting down $chosen_vm..."
		if virsh -c "$VIRSH_URI" shutdown "$chosen_vm"; then
			return 1 # Successfully shutdown, but don't switch workspace
		else
			show_message "Failed to shutdown $chosen_vm"
			return 1 # Explicit failure
		fi
	else
		return 1 # No VM selected
	fi
}

# Check for required dependencies
check_dependencies() {
	local missing=()

	# Check for virsh (libvirt-clients)
	if ! command -v virsh &>/dev/null; then
		missing+=("libvirt-clients (virsh)")
	fi

	# Check for virt-viewer
	if ! command -v virt-viewer &>/dev/null; then
		missing+=("virt-viewer")
	fi

	# Check for virt-manager (optional, but recommended)
	if ! command -v virt-manager &>/dev/null; then
		missing+=("virt-manager (optional GUI)")
	fi

	# If any dependencies are missing
	if [ ${#missing[@]} -gt 0 ]; then
		show_message "
    Missing required packages:
    $(printf '  - %s\n' "${missing[@]}")

    Checkout Debian: https://christitus.com/vm-setup-in-linux/

    Checkout Arch: https://christitus.com/setup-qemu-in-archlinux/
    "
		exit 1 # Exit with error
	fi
}

# Call the check before main_menu
check_dependencies

# Start the main menu
main_menu
