#!/bin/bash

################################################################################
# PowerVigil™ - Debian Package Builder
# 
# This script builds the PowerVigil .deb package for APT repository deployment
################################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${CYAN}${BOLD}PowerVigil™ Debian Package Builder${NC}"
echo "===================================="
echo ""

# Check for required tools
echo -e "${BLUE}Checking build dependencies...${NC}"
MISSING_DEPS=""

# Check for dpkg-dev (provides dpkg-buildpackage)
if ! command -v dpkg-buildpackage &> /dev/null; then
    MISSING_DEPS="$MISSING_DEPS dpkg-dev"
fi

# Check for debhelper
if ! dpkg -l debhelper 2>/dev/null | grep -q "^ii"; then
    MISSING_DEPS="$MISSING_DEPS debhelper"
fi

# Check for devscripts (provides dch)
if ! command -v dch &> /dev/null; then
    MISSING_DEPS="$MISSING_DEPS devscripts"
fi

# Check for build-essential
if ! dpkg -l build-essential 2>/dev/null | grep -q "^ii"; then
    MISSING_DEPS="$MISSING_DEPS build-essential"
fi

if [ -n "$MISSING_DEPS" ]; then
    echo -e "${YELLOW}Missing build dependencies:${NC}$MISSING_DEPS"
    echo ""
    echo "Install them with:"
    echo -e "${BOLD}sudo apt-get update && sudo apt-get install -y dpkg-dev debhelper devscripts build-essential${NC}"
    exit 1
fi

echo -e "${GREEN}  ✓${NC} All build dependencies satisfied"
echo ""

# Save original maintainer scripts
echo -e "${BLUE}Backing up maintainer scripts...${NC}"
cp debian/postinst debian/postinst.orig 2>/dev/null || true
cp debian/prerm debian/prerm.orig 2>/dev/null || true
cp debian/postrm debian/postrm.orig 2>/dev/null || true

# Clean previous builds
echo -e "${BLUE}Cleaning previous builds...${NC}"
rm -rf debian/powervigil
rm -f ../powervigil_*.deb
rm -f ../powervigil_*.dsc
rm -f ../powervigil_*.tar.*
rm -f ../powervigil_*.changes
rm -f ../powervigil_*.buildinfo

# Make scripts executable
chmod +x debian/rules
chmod +x debian/postinst
chmod +x debian/prerm
chmod +x debian/postrm
chmod +x debian/powervigil-* 2>/dev/null || true
chmod +x bin/*

# Build the package
echo -e "${BLUE}Building PowerVigil™ package...${NC}"
echo ""

# Build using dpkg-buildpackage (unsigned for local builds)
dpkg-buildpackage -us -uc -b

# Restore original maintainer scripts
echo -e "${BLUE}Restoring original maintainer scripts...${NC}"
if [ -f debian/postinst.orig ]; then
    mv debian/postinst.orig debian/postinst
fi
if [ -f debian/prerm.orig ]; then
    mv debian/prerm.orig debian/prerm
fi
if [ -f debian/postrm.orig ]; then
    mv debian/postrm.orig debian/postrm
fi

echo ""
echo -e "${GREEN}${BOLD}Package built successfully!${NC}"
echo ""
echo -e "${CYAN}Package location:${NC}"
ls -la ../powervigil_*.deb
echo ""
echo -e "${CYAN}To install locally:${NC}"
echo -e "  ${BOLD}sudo dpkg -i ../powervigil_*.deb${NC}"
echo -e "  ${BOLD}sudo apt-get install -f${NC}  # If there are dependency issues"
echo ""
echo -e "${CYAN}To add to APT repository:${NC}"
echo "  1. Copy the .deb file to your repository"
echo "  2. Run: dpkg-scanpackages . /dev/null | gzip -9c > Packages.gz"
echo "  3. Update repository metadata"
echo ""
echo -e "${CYAN}To test installation:${NC}"
echo -e "  ${BOLD}sudo apt-get update${NC}"
echo -e "  ${BOLD}sudo apt-get install powervigil${NC}"
echo ""
