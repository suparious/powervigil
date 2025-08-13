#!/bin/bash

################################################################################
# PowerVigil™ - Kiosk Performance & Recovery Framework
# Copyright (C) 2025 - GPL v3 License
# 
# Uninstallation Script
# Version: 1.0.0
################################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${CYAN}${BOLD}PowerVigil™ Uninstallation${NC}"
echo "=========================="
echo ""

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root${NC}"
   echo "Please run: sudo ./uninstall.sh"
   exit 1
fi

echo -e "${YELLOW}This will remove PowerVigil™ and restore default power management settings.${NC}"
read -p "Are you sure you want to continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Uninstallation cancelled."
    exit 0
fi

echo ""
echo -e "${CYAN}Stopping PowerVigil™ services...${NC}"
systemctl stop powervigil.service 2>/dev/null || true
systemctl stop powervigil-watchdog.service 2>/dev/null || true
systemctl disable powervigil.service 2>/dev/null || true
systemctl disable powervigil-watchdog.service 2>/dev/null || true

echo -e "${CYAN}Removing service files...${NC}"
rm -f /etc/systemd/system/powervigil.service
rm -f /etc/systemd/system/powervigil-watchdog.service
systemctl daemon-reload

echo -e "${CYAN}Removing executables...${NC}"
rm -f /usr/local/bin/powervigil-*
rm -f /usr/local/bin/powervigil-status

echo -e "${CYAN}Removing configuration files...${NC}"
rm -f /etc/X11/xorg.conf.d/10-powervigil.conf
rm -f /etc/X11/Xsession.d/99-powervigil
rm -f /etc/systemd/logind.conf.d/powervigil.conf
rm -f /etc/NetworkManager/conf.d/powervigil.conf
rm -f /etc/udev/rules.d/50-usb-autosuspend.rules

echo -e "${CYAN}Unmasking systemd targets...${NC}"
systemctl unmask sleep.target suspend.target hibernate.target hybrid-sleep.target

echo -e "${CYAN}Restoring CPU governor to default...${NC}"
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    echo "ondemand" > "$cpu" 2>/dev/null || echo "powersave" > "$cpu" 2>/dev/null || true
done

echo -e "${CYAN}Checking for configuration backups...${NC}"
if [ -f /var/lib/powervigil/last_backup ]; then
    LAST_BACKUP=$(cat /var/lib/powervigil/last_backup)
    if [ -d "$LAST_BACKUP" ]; then
        echo -e "${GREEN}Found backup at: $LAST_BACKUP${NC}"
        read -p "Restore from this backup? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            [ -f "$LAST_BACKUP/grub" ] && cp "$LAST_BACKUP/grub" /etc/default/grub
            update-grub 2>/dev/null || true
            echo -e "${GREEN}Configuration restored from backup${NC}"
        fi
    fi
fi

echo -e "${CYAN}Cleaning up PowerVigil™ directories...${NC}"
rm -rf /var/lib/powervigil
rm -rf /var/log/powervigil

echo ""
echo -e "${GREEN}${BOLD}PowerVigil™ has been uninstalled.${NC}"
echo ""
echo -e "${YELLOW}Note: Some changes require a reboot to fully revert:${NC}"
echo "  - Kernel boot parameters"
echo "  - Display manager settings"
echo ""
echo "Run ${BOLD}sudo systemctl reboot${NC} to complete the removal."
echo ""
