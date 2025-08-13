#!/bin/bash

################################################################################
# PowerVigil™ - Clean Build Artifacts
# 
# This script cleans all build artifacts and resets the repository to a clean state
################################################################################

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Cleaning PowerVigil™ build artifacts...${NC}"

# Reset any modified debian maintainer scripts
if git diff --quiet debian/postinst debian/prerm debian/postrm 2>/dev/null; then
    echo "  Maintainer scripts are clean"
else
    echo "  Resetting modified maintainer scripts..."
    git checkout -- debian/postinst debian/prerm debian/postrm 2>/dev/null || true
fi

# Clean build directories
echo "  Removing build directories..."
rm -rf debian/powervigil
rm -rf debian/.debhelper
rm -f debian/debhelper-build-stamp

# Clean build files
echo "  Removing build files..."
rm -f debian/*.debhelper
rm -f debian/*.debhelper.log
rm -f debian/*.substvars
rm -f debian/files
rm -f debian/*.orig

# Clean built packages
echo "  Removing built packages..."
rm -f ../powervigil_*.deb
rm -f ../powervigil_*.dsc
rm -f ../powervigil_*.tar.*
rm -f ../powervigil_*.changes
rm -f ../powervigil_*.buildinfo

echo -e "${GREEN}✓ Build artifacts cleaned${NC}"
echo ""
echo "Repository is now clean for:"
echo "  - git commit"
echo "  - Fresh build with ./build-deb.sh"
