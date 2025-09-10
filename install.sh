#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOGFILE="$SCRIPT_DIR/install.log"

# Create logfile if not exists
touch "$LOGFILE"

# Redirect stdout and stderr to logfile (and still show on screen)
exec > >(tee -a "$LOGFILE") 2>&1

# Logging function
log() {
	local level="$1"
	shift
	local msg="$*"
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $msg"
}

# Ask for sudo upfront
if [ "$EUID" -ne 0 ]; then
	echo "This script needs sudo privileges. Asking now..."
	sudo -v
	# Keep-alive: update existing `sudo` timestamp until script finishes
	while true; do
		sudo -n true
		sleep 60
		kill -0 "$$" || exit
	done 2>/dev/null &
fi

# Detect architecture
ARCH=$(uname -m)
case "$ARCH" in
x86_64) MACHINE="x86_64" ;;
aarch64) MACHINE="arm64" ;;
armv7l) MACHINE="armv7" ;;
*) echo "Unsupported arch: $ARCH" && exit 1 ;;
esac

# Detect distro
if [ -f /etc/arch-release ]; then
	DISTRO="arch"
elif [ -f /etc/debian_version ]; then
	DISTRO="debian"
else
	echo "Unsupported distro" && exit 1
fi

echo "Detected architecture: $MACHINE"
echo "Detected distro: $DISTRO"

# ────────────────────────────────────────────────
# Generic package installer
install_packages() {
	local packages=("$@")

	if [ ${#packages[@]} -eq 0 ]; then
		log ERROR "No packages specified for installation"
		return 1
	fi

	case "$DISTRO" in
	arch)
		if sudo pacman -Sy --noconfirm "${packages[@]}"; then
			log SUCCESS "Installed: ${packages[*]}"
			return 0
		else
			log ERROR "Failed to install: ${packages[*]}"
			return 1
		fi
		;;
	debian)
		if sudo apt-get update && sudo apt-get install -y "${packages[@]}"; then
			log SUCCESS "Installed: ${packages[*]}"
			return 0
		else
			log ERROR "Failed to install: ${packages[*]}"
			return 1
		fi
		;;
	*)
		log ERROR "Unsupported distro: $DISTRO"
		return 1
		;;
	esac
}

# ────────────────────────────────────────────────
# Package checker (returns missing packages in stdout)
check_packages() {
	local packages=("$@")
	local missing_pkgs=()

	if [ ${#packages[@]} -eq 0 ]; then
		log ERROR "No packages specified for checking"
		return 1
	fi

	case "$DISTRO" in
	arch)
		for pkg in "${packages[@]}"; do
			if ! pacman -Qi "$pkg" &>/dev/null; then
				missing_pkgs+=("$pkg")
			fi
		done
		;;
	debian)
		for pkg in "${packages[@]}"; do
			if ! dpkg -s "$pkg" &>/dev/null; then
				missing_pkgs+=("$pkg")
			fi
		done
		;;
	*)
		log ERROR "Unsupported distro: $DISTRO"
		return 1
		;;
	esac

	# Print missing packages (caller can capture with command substitution)
	echo "${missing_pkgs[@]}"
}

# ────────────────────────────────────────────────
# Global package lists (per category)

# i3wm setup packages
declare -A I3_PACKAGES=(
	[i3wm]="i3-wm"
	[polybar]="polybar"
	[rofi]="rofi"
	[dunst]="dunst"
	[picom]="picom"
	[betterlockscreen]="betterlockscreen"
)
: "${I3_PACKAGES[@]}"

# Dev tools packages
declare -A DEV_PACKAGES=(
	[neovim]="neovim"
	[alacritty]="alacritty"
	[tmux]="tmux"
)
: "${DEV_PACKAGES[@]}"

install_from_array() {
	local -n arr=$1 # create a nameref to the array
	local mode=$2
	local array_name=$1

	if [ "$mode" = "all" ]; then
		# Get all package values
		local all_packages=()
		for key in "${!arr[@]}"; do
			all_packages+=("${arr[$key]}")
		done

		log INFO "Installing all packages from $array_name..."

		if install_packages "${all_packages[@]}"; then
			log SUCCESS "Successfully installed all packages from $array_name"
			return 0
		else
			log ERROR "Failed to install some packages from $array_name"
			return 1
		fi

	elif [ "$mode" = "select" ]; then
		local selected_packages=()
		local msg=""
		local choice=""

		while true; do
			clear
			echo
			echo "=== Select Packages from $array_name ==="

			# Display packages with numbers
			local i=1
			local -A index_to_key
			for key in "${!arr[@]}"; do
				# Check if already selected
				local marker=""
				for pkg in "${selected_packages[@]}"; do
					if [ "$pkg" = "${arr[$key]}" ]; then
						marker=" [SELECTED]"
						break
					fi
				done
				echo "$i) $key (${arr[$key]})$marker"
				index_to_key[$i]=$key
				((i++))
			done

			echo "$msg"
			echo "==========================================="

			# Show install option only if packages are selected
			if [ ${#selected_packages[@]} -gt 0 ]; then
				echo "$i) Install selected packages (${#selected_packages[@]} selected)"
				local install_option=$i
				((i++))
			fi

			echo "$i) Back to previous menu"
			local back_option=$i

			read -rp "Choose an option: " choice

			if [[ "$choice" =~ ^[0-9]+$ ]]; then
				if [ "$choice" = "$back_option" ]; then
					return 0
				elif [ -n "${install_option:-}" ] && [ "$choice" = "$install_option" ]; then
					# Install selected packages
					log INFO "Installing selected packages..."
					if install_packages "${selected_packages[@]}"; then
						log SUCCESS "Installation completed"
						return 0
					else
						log ERROR "Installation failed"
						read -rp "Press Enter to continue..."
						return 1
					fi
				elif [ -n "${index_to_key[$choice]:-}" ]; then
					# Add/remove package from selection
					local key="${index_to_key[$choice]}"
					local pkg="${arr[$key]}"

					# Check if already selected
					local already_selected=0
					for selected_pkg in "${selected_packages[@]}"; do
						if [ "$selected_pkg" = "$pkg" ]; then
							already_selected=1
							break
						fi
					done

					if [ $already_selected -eq 1 ]; then
						log WARN "Package '$key' is already selected"
						msg="Package '$key' is already selected"
					else
						selected_packages+=("$pkg")
						log INFO "Added '$key' to selection"
						msg=""
					fi
				else
					log ERROR "Invalid option"
					msg="Invalid option '$choice'"
				fi
			else
				log ERROR "Invalid option '$choice'"
				msg="Invalid option '$choice'"
			fi
		done
	else
		log ERROR "Invalid mode: $mode"
		return 1
	fi
}

install_i3wm_setup() {
	local msg=""
	local choice=""
	while true; do
		clear
		echo
		echo "=== i3wm Setup Packages ==="
		echo "1) Install all i3 setup tools"
		echo "2) Select tools to install"
		echo "3) Back to main menu"
		echo "$error"
		echo "=============================="
		read -rp "Choose an option: " choice

		case "$choice" in
		1)
			install_from_array I3_PACKAGES "all"
			error=""
			continue
			;;
		2)
			install_from_array I3_PACKAGES "select"
			error=""
			continue
			;;
		3) return ;;
		*)
			error="Invalid option '$choice'"
			log ERROR "Invalid option '$choice'"
			;;
		esac
	done

}

install_dev_tools() {
	local error=""
	local choice=""
	while true; do
		clear
		echo
		echo "=== Dev Tools Installation ==="
		echo "1) Install all dev tools"
		echo "2) Select tools to install"
		echo "3) Back to main menu"
		echo "$error"
		echo "=============================="
		read -rp "Choose an option: " choice

		case "$choice" in
		1)
			install_from_array DEV_PACKAGES "all"
			error=""
			continue
			;;
		2)
			install_from_array DEV_PACKAGES "select"
			error=""
			continue
			;;
		3) return ;;
		*)
			error="Invalid option '$choice'"
			log ERROR "Invalid option '$choice'"
			;;
		esac
	done
}

# ────────────────────────────────────────────────
# Main Menu Function
main_menu() {
	local error=""
	local choice=""
	while true; do
		clear
		echo
		echo "=== Setup Menu (Distro: $DISTRO | Arch: $MACHINE) ==="
		echo "1) Install i3wm setup"
		echo "2) Install dev tools"
		echo "3) Exit"
		echo "$error"
		echo "====================================================="
		read -rp "Choose an option: " choice

		case "$choice" in
		1)
			install_i3wm_setup
			error=""
			;;
		2)
			install_dev_tools
			error=""
			;;
		3)
			echo "Bye!"
			exit 0
			;;
		*)
			error="Invalid option '$choice'"
			log ERROR "Invalid option '$choice'"
			;;
		esac
	done
}

main_menu
