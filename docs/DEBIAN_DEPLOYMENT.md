# PowerVigil™ Debian Package & APT Repository Deployment

## Overview

This guide covers deploying PowerVigil™ to thousands of kiosks via Debian packages and APT repositories, enabling zero-touch installation and centralized updates.

## Quick Start

### 1. Build the Package

```bash
# Install build dependencies (one-time)
sudo apt-get install build-essential debhelper devscripts

# Build the package
./build-deb.sh

# Package will be created as: ../powervigil_1.0.0-1_all.deb
```

### 2. Test Local Installation

```bash
# Install locally to test
sudo dpkg -i ../powervigil_1.0.0-1_all.deb

# Verify installation
sudo powervigil-verify
```

## APT Repository Setup

### Repository Structure

```
/var/www/apt/
├── dists/
│   └── stable/
│       ├── Release
│       ├── Release.gpg
│       ├── InRelease
│       └── main/
│           └── binary-all/
│               ├── Packages
│               └── Packages.gz
└── pool/
    └── main/
        └── p/
            └── powervigil/
                └── powervigil_1.0.0-1_all.deb
```

### Setting Up Your Repository

1. **Create repository structure:**
```bash
mkdir -p /var/www/apt/{dists/stable/main/binary-all,pool/main/p/powervigil}
```

2. **Copy package to repository:**
```bash
cp powervigil_1.0.0-1_all.deb /var/www/apt/pool/main/p/powervigil/
```

3. **Generate package metadata:**
```bash
cd /var/www/apt
dpkg-scanpackages pool/main /dev/null > dists/stable/main/binary-all/Packages
gzip -9c dists/stable/main/binary-all/Packages > dists/stable/main/binary-all/Packages.gz
```

4. **Create Release file:**
```bash
apt-ftparchive release dists/stable > dists/stable/Release
```

5. **Sign repository (optional but recommended):**
```bash
gpg --default-key YOUR-KEY-ID -abs -o dists/stable/Release.gpg dists/stable/Release
gpg --default-key YOUR-KEY-ID --clearsign -o dists/stable/InRelease dists/stable/Release
```

## Kiosk Configuration

### Add Repository to Kiosks

Create `/etc/apt/sources.list.d/powervigil.list`:
```
deb http://your-repo.example.com/apt stable main
```

### Mass Deployment Options

#### Option 1: Push via Configuration Management

**Ansible Example:**
```yaml
---
- name: Deploy PowerVigil to all kiosks
  hosts: kiosks
  become: yes
  tasks:
    - name: Add PowerVigil repository
      apt_repository:
        repo: "deb http://repo.example.com/apt stable main"
        state: present
        
    - name: Install PowerVigil
      apt:
        name: powervigil
        state: latest
        update_cache: yes
        
    - name: Schedule reboot if required
      reboot:
        msg: "PowerVigil activation"
        pre_reboot_delay: 300
      when: ansible_facts['file_exists'] == '/var/lib/powervigil/reboot-required'
```

**Puppet Example:**
```puppet
class powervigil {
  apt::source { 'powervigil':
    location => 'http://repo.example.com/apt',
    release  => 'stable',
    repos    => 'main',
  }
  
  package { 'powervigil':
    ensure  => latest,
    require => Apt::Source['powervigil'],
  }
  
  reboot { 'powervigil_activation':
    when    => 'finished',
    onlyif  => 'test -f /var/lib/powervigil/reboot-required',
  }
}
```

#### Option 2: Automatic Updates via APT

Enable unattended-upgrades on kiosks:
```bash
# Install unattended-upgrades
apt-get install unattended-upgrades

# Configure for PowerVigil
echo 'Unattended-Upgrade::Origins-Pattern {
        "origin=your-repo";
};' > /etc/apt/apt.conf.d/51powervigil-upgrades
```

#### Option 3: PowerVigil Auto-Update Timer

PowerVigil includes its own update mechanism:
```bash
# Enable auto-updates (runs daily at 2 AM)
systemctl enable powervigil-update.timer
systemctl start powervigil-update.timer

# Check timer status
systemctl list-timers powervigil-update.timer
```

## Version Management

### Updating PowerVigil

1. **Update version number:**
```bash
# Edit debian/changelog
dch -v 1.0.1-1 "Bug fixes and performance improvements"

# Update VERSION file
echo "1.0.1" > VERSION
```

2. **Build new package:**
```bash
./build-deb.sh
```

3. **Deploy to repository:**
```bash
# Copy to repository
scp ../powervigil_1.0.1-1_all.deb repo:/var/www/apt/pool/main/p/powervigil/

# Update repository metadata
ssh repo "cd /var/www/apt && dpkg-scanpackages pool/main /dev/null | gzip -9c > dists/stable/main/binary-all/Packages.gz"
```

4. **Kiosks will automatically update:**
- Via unattended-upgrades (if configured)
- Via PowerVigil auto-update timer
- Via manual `apt-get update && apt-get upgrade`

## Deployment Scenarios

### Scenario 1: Initial Rollout (20,000 kiosks)

```bash
# 1. Add to your standard kiosk image
echo "deb http://repo.example.com/apt stable main" > /etc/apt/sources.list.d/powervigil.list

# 2. Include in base package list
echo "powervigil" >> /etc/kiosk/required-packages.txt

# 3. Deploy via your existing mechanism
ansible-playbook -i inventory/kiosks deploy-powervigil.yml --forks=100
```

### Scenario 2: Gradual Rollout

```bash
# Test on staging kiosks first
ansible-playbook deploy-powervigil.yml --limit="staging-kiosks"

# Roll out to 10% of production
ansible-playbook deploy-powervigil.yml --limit="kiosks[0:2000]"

# Complete rollout after validation
ansible-playbook deploy-powervigil.yml --limit="kiosks[2000:]"
```

### Scenario 3: Emergency Update

```bash
# Build hotfix version
dch -v 1.0.0-2 "Critical fix for display recovery"
./build-deb.sh

# Deploy to repository
./deploy-to-apt.sh

# Force immediate update on all kiosks
ansible kiosks -m shell -a "apt-get update && apt-get install -y powervigil && systemctl reboot" --forks=100
```

## Monitoring Deployment

### Check Installation Status

```bash
# Via Ansible
ansible kiosks -m shell -a "dpkg -l powervigil | grep ^ii" --forks=100

# Via custom script
for kiosk in $(cat kiosk-list.txt); do
    ssh $kiosk "powervigil-verify" &
done
wait
```

### Collect Logs

```bash
# Centralized logging setup
rsyslog configuration on kiosks:
:programname, isequal, "powervigil" @@logserver:514
```

### Health Dashboard

Create monitoring dashboard checking:
- Package version: `dpkg-query -W -f='${Version}' powervigil`
- Service status: `systemctl is-active powervigil.service`
- Watchdog status: `systemctl is-active powervigil-watchdog.service`
- Last update: `stat -c %y /var/lib/powervigil/installed`

## Troubleshooting

### Package Installation Issues

```bash
# Check apt logs
tail -f /var/log/apt/history.log
tail -f /var/log/apt/term.log

# Verify repository accessibility
curl http://repo.example.com/apt/dists/stable/Release

# Force reinstall
apt-get install --reinstall powervigil
```

### Service Not Starting

```bash
# Check service status
systemctl status powervigil.service
journalctl -u powervigil.service -n 50

# Manually run configuration
sudo powervigil-config --auto

# Verify after reboot
sudo powervigil-verify
```

### Update Not Applying

```bash
# Check held packages
apt-mark showhold

# Check package version
apt-cache policy powervigil

# Force update
apt-get update
apt-get install powervigil=1.0.1-1
```

## Best Practices

1. **Test Updates**: Always test on staging kiosks first
2. **Stagger Rollouts**: Deploy to groups to avoid overloading repository
3. **Monitor Bandwidth**: Repository may need CDN for 20,000 kiosks
4. **Keep Backups**: Maintain previous .deb versions for rollback
5. **Document Changes**: Update changelog for every version
6. **Sign Packages**: Use GPG signing for security
7. **Use HTTPS**: Secure repository communication
8. **Rate Limiting**: Configure Apache/Nginx rate limits
9. **Mirror Repositories**: Consider geographic mirrors for global deployment
10. **Automate Testing**: CI/CD pipeline for package building

## Integration Examples

### With Existing Kiosk Management

```bash
# Add to your kiosk provisioning script
install_powervigil() {
    echo "Installing PowerVigil..."
    echo "deb http://repo.example.com/apt stable main" > /etc/apt/sources.list.d/powervigil.list
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y powervigil
    
    if [ -f /var/lib/powervigil/reboot-required ]; then
        echo "Scheduling reboot for PowerVigil activation..."
        shutdown -r +10 "PowerVigil activation reboot"
    fi
}

# Call during provisioning
install_powervigil
```

### With Monitoring Systems

```python
# Nagios/Icinga check script
#!/usr/bin/env python3
import subprocess
import sys

def check_powervigil():
    try:
        result = subprocess.run(['powervigil-verify'], 
                              capture_output=True, text=True)
        if result.returncode == 0:
            print("OK: PowerVigil fully operational")
            sys.exit(0)
        else:
            print(f"WARNING: PowerVigil issues detected")
            sys.exit(1)
    except Exception as e:
        print(f"CRITICAL: PowerVigil check failed: {e}")
        sys.exit(2)

if __name__ == "__main__":
    check_powervigil()
```

## Advanced Configuration

### Custom Repository with Authentication

```nginx
server {
    listen 443 ssl;
    server_name repo.example.com;
    
    ssl_certificate /etc/nginx/ssl/repo.crt;
    ssl_certificate_key /etc/nginx/ssl/repo.key;
    
    location /apt {
        auth_basic "PowerVigil Repository";
        auth_basic_user_file /etc/nginx/.htpasswd;
        
        alias /var/www/apt;
        autoindex on;
        
        # Rate limiting
        limit_req zone=apt_limit burst=10 nodelay;
    }
}
```

### Repository Mirroring

```bash
# Sync to mirror
rsync -avz --delete /var/www/apt/ mirror1:/var/www/apt/
rsync -avz --delete /var/www/apt/ mirror2:/var/www/apt/

# GeoDNS configuration for repo.example.com
# Points to nearest mirror based on location
```

## Conclusion

PowerVigil™'s Debian package design enables:
- ✅ Zero-touch deployment to 20,000+ kiosks
- ✅ Automatic configuration on installation
- ✅ Centralized version control
- ✅ Scheduled maintenance windows
- ✅ Rollback capabilities
- ✅ Comprehensive logging
- ✅ Integration with existing infrastructure

The package handles all configuration automatically, requiring only a reboot to activate, making it ideal for large-scale kiosk deployments.
