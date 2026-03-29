#!/bin/bash
echo "========== Starting system update ==========" >>/var/log/system-update.log
date >>/var/log/system-update.log
/usr/bin/pacman -Syu --noconfirm >>/var/log/system-update.log 2>&1
echo "========== Update finished ==========" >>/var/log/system-update.log
echo "" >>/var/log/system-update.log
