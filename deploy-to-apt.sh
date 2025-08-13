#!/bin/bash

################################################################################
# PowerVigil™ - APT Repository Management Guide
# 
# This script provides instructions and automation for deploying PowerVigil
# to your custom APT repository for mass deployment to kiosks
################################################################################

set -e

# Configuration - Adjust these for your environment
REPO_HOST="your-repo.example.com"
REPO_PATH="/var/www/apt"
REPO_USER="repo-admin"
GPG_KEY_ID="your-gpg-key-id"

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${CYAN}${BOLD}PowerVigil™ APT Repository Deployment Guide${NC}"
echo "============================================"
echo ""

echo -e "${GREEN}Step 1: Build the Package${NC}"
echo "-------------------------"
echo "Run: ./build-deb.sh"
echo ""

echo -e "${GREEN}Step 2: Sign the Package (Optional but Recommended)${NC}"
echo "----------------------------------------------------"
echo "If you have a GPG key for your repository:"
echo "  dpkg-sig --sign builder ../powervigil_*.deb"
echo ""

echo -e "${GREEN}Step 3: Copy to Repository Server${NC}"
echo "---------------------------------"
echo "Example command:"
echo "  scp ../powervigil_*.deb ${REPO_USER}@${REPO_HOST}:${REPO_PATH}/pool/main/p/powervigil/"
echo ""

echo -e "${GREEN}Step 4: Update Repository Metadata${NC}"
echo "----------------------------------"
echo "On your repository server, run:"
echo ""
cat << 'EOF'
# Navigate to repository root
cd /var/www/apt

# Update package lists
dpkg-scanpackages pool/main /dev/null | gzip -9c > dists/stable/main/binary-all/Packages.gz
dpkg-scanpackages pool/main /dev/null > dists/stable/main/binary-all/Packages

# Generate Release file
apt-ftparchive release dists/stable > dists/stable/Release

# Sign Release file (if using signed repository)
gpg --default-key YOUR-KEY-ID -abs -o dists/stable/Release.gpg dists/stable/Release
gpg --default-key YOUR-KEY-ID --clearsign -o dists/stable/InRelease dists/stable/Release
EOF
echo ""

echo -e "${GREEN}Step 5: Configure Kiosks to Use Repository${NC}"
echo "------------------------------------------"
echo "Add this to /etc/apt/sources.list.d/custom.list on each kiosk:"
echo "  deb http://${REPO_HOST}/apt stable main"
echo ""

echo -e "${GREEN}Step 6: Mass Deployment Script${NC}"
echo "------------------------------"
echo "Create this script for kiosk deployment:"
echo ""
cat << 'DEPLOY_SCRIPT'
#!/bin/bash
# PowerVigil Kiosk Deployment Script

# Update package lists
apt-get update

# Install PowerVigil (will auto-configure on installation)
DEBIAN_FRONTEND=noninteractive apt-get install -y powervigil

# Check if reboot is required
if [ -f /var/lib/powervigil/reboot-required ]; then
    echo "PowerVigil installed - reboot required"
    # Schedule reboot for maintenance window
    # shutdown -r +60 "System will reboot in 60 minutes for PowerVigil activation"
fi

# Verify installation
powervigil-verify
DEPLOY_SCRIPT
echo ""

echo -e "${GREEN}Step 7: Ansible Playbook Example${NC}"
echo "--------------------------------"
cat << 'ANSIBLE'
---
- name: Deploy PowerVigil to Kiosks
  hosts: kiosks
  become: yes
  tasks:
    - name: Ensure custom repository is configured
      apt_repository:
        repo: "deb http://your-repo.example.com/apt stable main"
        state: present
        
    - name: Update apt cache
      apt:
        update_cache: yes
        
    - name: Install PowerVigil
      apt:
        name: powervigil
        state: latest
        
    - name: Check if reboot required
      stat:
        path: /var/lib/powervigil/reboot-required
      register: reboot_required
      
    - name: Schedule reboot if required
      reboot:
        msg: "Rebooting for PowerVigil activation"
        pre_reboot_delay: 60
      when: reboot_required.stat.exists
      
    - name: Verify PowerVigil status
      command: powervigil-verify
      register: verify_result
      changed_when: false
      
    - name: Display verification results
      debug:
        var: verify_result.stdout_lines
ANSIBLE
echo ""

echo -e "${GREEN}Step 8: Version Management${NC}"
echo "-------------------------"
echo "To update PowerVigil on all kiosks:"
echo "  1. Update version in debian/changelog"
echo "  2. Build new package with ./build-deb.sh"
echo "  3. Upload to repository"
echo "  4. Run: apt-get update && apt-get upgrade on kiosks"
echo ""

echo -e "${YELLOW}${BOLD}Important Notes:${NC}"
echo "• PowerVigil auto-configures on installation"
echo "• Reboot is required but can be scheduled"
echo "• Services start automatically after reboot"
echo "• No manual intervention required"
echo "• Logs available at /var/log/powervigil/"
echo ""

echo -e "${CYAN}${BOLD}Mass Deployment Benefits:${NC}"
echo "✓ Zero-touch installation"
echo "✓ Automatic configuration"
echo "✓ Centralized version control"
echo "✓ Easy rollback (keep previous .deb versions)"
echo "✓ Audit trail via apt logs"
echo ""
