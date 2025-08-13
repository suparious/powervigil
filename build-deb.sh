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

for tool in debhelper dh-make fakeroot; do
    if ! command -v $tool &> /dev/null; then
        MISSING_DEPS="$MISSING_DEPS $tool"
    fi
done

if [ -n "$MISSING_DEPS" ]; then
    echo -e "${YELLOW}Missing build dependencies:${NC}$MISSING_DEPS"
    echo ""
    echo "Install them with:"
    echo -e "${BOLD}sudo apt-get install build-essential debhelper devscripts dh-make fakeroot${NC}"
    exit 1
fi

echo -e "${GREEN}  ✓${NC} All build dependencies satisfied"
echo ""

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
chmod +x debian/powervigil-*
chmod +x bin/*

# Build the package
echo -e "${BLUE}Building PowerVigil™ package...${NC}"
echo ""

# Build using dpkg-buildpackage
dpkg-buildpackage -us -uc -b

echo ""
echo -e "${GREEN}${BOLD}Package built successfully!${NC}"
echo ""
echo -e "${CYAN}Package location:${NC}"
ls -la ../powervigil_*.deb
echo ""
echo -e "${CYAN}To install locally:${NC}"
echo -e "  ${BOLD}sudo dpkg -i ../powervigil_*.deb${NC}"
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
