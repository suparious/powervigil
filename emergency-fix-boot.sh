#!/bin/bash

################################################################################
# PowerVigil™ EMERGENCY FIX for v1.0.1 Boot Issues
# 
# This script removes dangerous kernel parameters that prevent systems from booting
# Run this on any system that had v1.0.1 installed
################################################################################

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${RED}${BOLD}═══════════════════════════════════════════════════════════════════${NC}"
echo -e "${RED}${BOLD}  PowerVigil™ EMERGENCY FIX - Boot Issue Resolution${NC}"
echo -e "${RED}${BOLD}═══════════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}This script fixes the boot issues caused by PowerVigil v1.0.1${NC}"
echo -e "${YELLOW}which added kernel parameters that break modern UEFI systems.${NC}"
echo ""

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root${NC}"
   echo "Please run: sudo $0"
   exit 1
fi

echo -e "${CYAN}Backing up current GRUB configuration...${NC}"
cp /etc/default/grub /etc/default/grub.backup.emergency.$(date +%Y%m%d_%H%M%S)

echo -e "${CYAN}Removing dangerous kernel parameters...${NC}"
# Remove the dangerous parameters
sed -i 's/acpi=off//g' /etc/default/grub
sed -i 's/apm=off//g' /etc/default/grub
sed -i 's/noapic//g' /etc/default/grub
sed -i 's/nolapic//g' /etc/default/grub
sed -i 's/idle=poll//g' /etc/default/grub

# Change max_cstate from 0 to 1 (0 can cause issues on some systems)
sed -i 's/intel_idle.max_cstate=0/intel_idle.max_cstate=1/g' /etc/default/grub
sed -i 's/processor.max_cstate=0/processor.max_cstate=1/g' /etc/default/grub

# Clean up any multiple spaces left behind
sed -i 's/  */ /g' /etc/default/grub

echo -e "${GREEN}✓${NC} Dangerous parameters removed"
echo ""
echo -e "${CYAN}Current kernel parameters:${NC}"
grep "GRUB_CMDLINE_LINUX_DEFAULT" /etc/default/grub
echo ""

echo -e "${CYAN}Updating GRUB...${NC}"
update-grub

echo ""
echo -e "${GREEN}${BOLD}═══════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}${BOLD}  EMERGENCY FIX COMPLETE${NC}"
echo -e "${GREEN}${BOLD}═══════════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${CYAN}Safe parameters that remain:${NC}"
echo "  • consoleblank=0 - Prevents console blanking"
echo "  • intel_idle.max_cstate=1 - Limits CPU idle states (safe)"
echo "  • processor.max_cstate=1 - Limits processor idle states (safe)"
echo ""
echo -e "${RED}${BOLD}Removed dangerous parameters:${NC}"
echo "  ✗ acpi=off - Was breaking hardware detection"
echo "  ✗ noapic - Was breaking interrupt handling"
echo "  ✗ nolapic - Was breaking local interrupts"
echo "  ✗ idle=poll - Too aggressive for most systems"
echo ""
echo -e "${YELLOW}${BOLD}IMPORTANT: Please reboot now to apply the fixes${NC}"
echo -e "${CYAN}Run: ${BOLD}sudo reboot${NC}"
echo ""
echo "After reboot, install PowerVigil v1.0.2 which has this fix built-in"
