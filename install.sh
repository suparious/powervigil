#!/bin/bash

################################################################################
# PowerVigil™ - Kiosk Performance & Recovery Framework
# Copyright (C) 2025 - GPL v3 License
# 
# Installation Script
# Version: 1.0.0
################################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# PowerVigil™ banner
show_banner() {
    echo -e "${CYAN}${BOLD}"
    echo "═══════════════════════════════════════════════════════════════════"
    echo "   ____                        _   ___      _ _ ™                  "
    echo "  |  _ \ _____      _____ _ __| | / (_) __ _(_) |                 "
    echo "  | |_) / _ \ \ /\ / / _ \ '__| |/ /| |/ _\` | | |                "
    echo "  |  __/ (_) \ V  V /  __/ |   \   / | | (_| | | |                "
    echo "  |_|   \___/ \_/\_/ \___|_|    \_/  |_|\__, |_|_|                "
    echo "                                         |___/                      "
    echo "═══════════════════════════════════════════════════════════════════"
    echo -e "${NC}${MAGENTA}${BOLD}  Installation Script v1.0.0${NC}"
    echo "═══════════════════════════════════════════════════════════════════"
    echo ""
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root${NC}"
   echo "Please run: sudo ./install.sh"
   exit 1
fi

show_banner

echo -e "${BLUE}Starting PowerVigil™ installation...${NC}"
echo ""

# Create directories
echo -e "${CYAN}Creating directories...${NC}"
mkdir -p /usr/local/bin
mkdir -p /etc/systemd/system
mkdir -p /var/lib/powervigil
mkdir -p /var/log/powervigil
mkdir -p /var/backups/powervigil

# Install executables
echo -e "${CYAN}Installing PowerVigil™ executables...${NC}"
cp bin/powervigil-config /usr/local/bin/
cp bin/powervigil-verify /usr/local/bin/
cp bin/powervigil-watchdog /usr/local/bin/
chmod +x /usr/local/bin/powervigil-*
echo -e "  ${GREEN}✓${NC} Executables installed"

# Create symbolic links for easier access
ln -sf /usr/local/bin/powervigil-verify /usr/local/bin/powervigil-status
echo -e "  ${GREEN}✓${NC} Symbolic links created"

# Install systemd services
echo -e "${CYAN}Installing systemd services...${NC}"
cp systemd/powervigil.service /etc/systemd/system/
cp systemd/powervigil-watchdog.service /etc/systemd/system/
systemctl daemon-reload
echo -e "  ${GREEN}✓${NC} Systemd services installed"

# Create recovery script
echo -e "${CYAN}Creating recovery script...${NC}"
cat > /usr/local/bin/powervigil-recover << 'EOF'
#!/bin/bash
# PowerVigil™ Quick Recovery Script

echo "PowerVigil™ Display Recovery"
echo "============================"
echo "Attempting to recover unresponsive display..."

# Force display on
DISPLAY=:0 xset dpms force on 2>/dev/null || true

# Reset DPMS and blanking
DISPLAY=:0 xset -dpms 2>/dev/null || true
DISPLAY=:0 xset s off 2>/dev/null || true
DISPLAY=:0 xset s noblank 2>/dev/null || true
DISPLAY=:0 xset s 0 0 2>/dev/null || true

# Send wake event
DISPLAY=:0 xdotool key Shift 2>/dev/null || true

# Reset GPU if NVIDIA
if command -v nvidia-smi &> /dev/null; then
    nvidia-smi -pm 1 2>/dev/null || true
fi

echo "Recovery attempt complete."
echo ""
echo "If display is still unresponsive, run:"
echo "  sudo systemctl restart gdm3  # or lightdm/sddm"
EOF
chmod +x /usr/local/bin/powervigil-recover
echo -e "  ${GREEN}✓${NC} Recovery script created"

# Create monitoring script
echo -e "${CYAN}Creating monitoring script...${NC}"
cat > /usr/local/bin/powervigil-monitor << 'EOF'
#!/bin/bash
# PowerVigil™ Real-time Monitor

echo "PowerVigil™ Real-time Monitor"
echo "============================="
echo "Press Ctrl+C to exit"
echo ""

watch -n 1 '
echo "=== PowerVigil™ Status ==="
echo ""
echo "CPU Governor:"
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo ""
echo "Service Status:"
systemctl is-active powervigil.service powervigil-watchdog.service
echo ""
echo "Recent Watchdog Activity:"
tail -n 5 /var/log/powervigil/watchdog.log 2>/dev/null || echo "No watchdog logs yet"
echo ""
echo "Display Status:"
DISPLAY=:0 timeout 1 xset q 2>/dev/null | grep -A 1 "DPMS" || echo "Cannot query display"
'
EOF
chmod +x /usr/local/bin/powervigil-monitor
echo -e "  ${GREEN}✓${NC} Monitoring script created"

echo ""
echo -e "${YELLOW}${BOLD}Installation complete!${NC}"
echo ""
echo -e "${CYAN}Next steps:${NC}"
echo "1. Run PowerVigil™ configuration:"
echo -e "   ${BOLD}sudo powervigil-config${NC}"
echo ""
echo "2. Enable and start services:"
echo -e "   ${BOLD}sudo systemctl enable powervigil.service${NC}"
echo -e "   ${BOLD}sudo systemctl enable powervigil-watchdog.service${NC}"
echo -e "   ${BOLD}sudo systemctl start powervigil.service${NC}"
echo -e "   ${BOLD}sudo systemctl start powervigil-watchdog.service${NC}"
echo ""
echo "3. Reboot the system:"
echo -e "   ${BOLD}sudo systemctl reboot${NC}"
echo ""
echo "4. After reboot, verify installation:"
echo -e "   ${BOLD}sudo powervigil-verify${NC}"
echo ""
echo -e "${GREEN}${BOLD}PowerVigil™ is ready to protect your displays!${NC}"
echo ""
