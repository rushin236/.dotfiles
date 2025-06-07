#!/usr/bin/env bash

# VM Manager for i3 with Rofi (no notify-send version)
# Requires: virt-manager, virsh, virt-viewer, rofi

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
		return
	fi

	local chosen_vm
	chosen_vm=$(echo "$vms" | rofi -dmenu -p "Select VM to start" $ROFI_THEME)

	if [ -n "$chosen_vm" ]; then
		show_message "Starting $chosen_vm..."
		virt-viewer -c "$VIRSH_URI" -a "$chosen_vm" &>/dev/null &
	fi
}

start_vm_from_snapshot() {
	local vms
	vms=$(virsh -c "$VIRSH_URI" list --all --name | grep -v "^$" | sort)

	if [ -z "$vms" ]; then
		show_message "No VMs found"
		return
	fi

	local chosen_vm
	chosen_vm=$(echo "$vms" | rofi -dmenu -p "Select VM" $ROFI_THEME)

	if [ -z "$chosen_vm" ]; then
		return
	fi

	local snapshots
	snapshots=$(virsh -c "$VIRSH_URI" snapshot-list "$chosen_vm" --name | grep -v "^$" | sort)

	if [ -z "$snapshots" ]; then
		show_message "No snapshots found for $chosen_vm"
		return
	fi

	local chosen_snapshot
	chosen_snapshot=$(echo "$snapshots" | rofi -dmenu -p "Select snapshot for $chosen_vm" $ROFI_THEME)

	if [ -n "$chosen_snapshot" ]; then
		show_message "Starting $chosen_vm from snapshot $chosen_snapshot..."
		virsh -c "$VIRSH_URI" snapshot-revert "$chosen_vm" "$chosen_snapshot"
		virt-viewer -c "$VIRSH_URI" -a "$chosen_vm" &>/dev/null &
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
}

shutdown_vm() {
	local running_vms
	running_vms=$(virsh -c "$VIRSH_URI" list --name | grep -v "^$")

	if [ -z "$running_vms" ]; then
		show_message "No running VMs to shutdown"
		return
	fi

	local chosen_vm
	chosen_vm=$(echo "$running_vms" | rofi -dmenu -p "Select VM to shutdown" $ROFI_THEME)

	if [ -n "$chosen_vm" ]; then
		show_message "Shutting down $chosen_vm..."
		virsh -c "$VIRSH_URI" shutdown "$chosen_vm"
	fi
}

# Start the main menu
main_menu
