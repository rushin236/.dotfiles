#!/bin/bash

if ! command -v yay &>/dev/null; then
	echo "yay is not installed. Installing yay..."
	sudo pacman -S --needed --noconfirm git base-devel
	git clone https://aur.archlinux.org/yay.git /tmp/yay
	cd /tmp/yay
	makepkg -si --noconfirm
else
	echo "yay is already installed."
fi

PAC_PACKAGES=(
	i3-wm
	rofi
	picom
	polybar
	i3lock
	dex
	dunst
	feh
	flameshot
	alacritty
	pulseaudio
	pavucontrol
	polkit-gnome
	xautolock
	xss-lock
	argyllcms
	easyeffects
	calf
	lsp-plugins-lv2
	zam-plugins-lv2
	mda.lv2
	yelp
)

YAY_PACKAGES=(
	yazi
	coolercontrol-bin
)

echo "Installing base packages with pacman..."
sudo pacman -Syu --noconfirm "${PAC_PACKAGES[@]}"

echo "Installing base packages with yay..."
yay -Syu --noconfirm "${YAY_PACKAGES[@]}"

SHELL_PACKAGES=(zsh neovim tmux stow)

echo "Installing shell packages with yay"
yay -Syu --noconfirm "${SHELL_PACKAGES[@]}"

echo "Setting up config for all"
