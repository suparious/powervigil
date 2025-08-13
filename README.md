# PowerVigil™ - Kiosk Performance & Recovery Framework

<div align="center">

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![License](https://img.shields.io/badge/license-GPL%20v3-green.svg)
![Platform](https://img.shields.io/badge/platform-Debian%2013%20%28Trixie%29-orange.svg)
![Status](https://img.shields.io/badge/status-production--ready-brightgreen.svg)

**Your display's guardian against sleep, slowdown, and system fatigue**

*Eternal vigilance for your kiosk displays*

</div>

---

## 🛡️ Overview

PowerVigil™ is a comprehensive power management solution designed specifically for kiosk systems, digital signage, and always-on displays. It ensures your displays remain responsive and performant 24/7 by implementing a multi-layered approach to disable power management across all system levels.

### ✨ Key Features

- **🔥 ZeroSleep Technology™** - Complete elimination of all sleep states
- **⚡ Performance Lock Engine** - CPU and GPU locked at maximum performance
- **🔄 AutoRecover Watchdog** - Automatic detection and recovery from display issues
- **🛡️ 13-Layer Protection Matrix** - Redundant safeguards at every system level
- **📊 Real-time Monitoring** - Comprehensive logging and status verification
- **🔧 One-Click Installation** - Simple deployment with automatic configuration

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/suparious/powervigil.git
cd powervigil

# Run the installer
sudo ./install.sh

# Verify installation
sudo ./bin/powervigil-verify
```

## 📋 Requirements

- **Operating System**: Debian 13 (Trixie) or compatible
- **Privileges**: Root access required for installation
- **Display Server**: X11 or Wayland
- **Desktop Environment**: GNOME, KDE, XFCE, or bare X11

## 🏗️ Architecture

PowerVigil™ implements protection at multiple system levels:

| Layer | Component | Protection |
|-------|-----------|------------|
| 1 | Kernel | Boot parameters disable all power management |
| 2 | Systemd | Sleep/suspend targets masked |
| 3 | CPU Governor | Locked to performance mode |
| 4 | GPU Management | Maximum performance profiles |
| 5 | Display Server | DPMS completely disabled |
| 6 | Console | Blanking eliminated |
| 7 | USB Subsystem | Autosuspend prevented |
| 8 | Network | WiFi power saving disabled |
| 9 | ACPI | Power events ignored |
| 10 | Desktop Environment | Idle actions disabled |
| 11 | Screensavers | Removed/disabled |
| 12 | Watchdog Service | Active monitoring |
| 13 | Recovery System | Automatic restoration |

## 📦 What's Included

```
powervigil/
├── bin/                      # Executable scripts
│   ├── powervigil-config    # Main configuration tool
│   ├── powervigil-verify    # Verification utility
│   └── powervigil-watchdog  # Monitoring daemon
├── systemd/                  # Service definitions
│   ├── powervigil.service
│   └── powervigil-watchdog.service
├── docs/                     # Documentation
│   ├── TROUBLESHOOTING.md
│   └── ARCHITECTURE.md
├── install.sh               # Installation script
├── uninstall.sh            # Clean removal script
├── LICENSE                 # GPL v3
└── README.md              # This file
```

## 🔧 Installation

### Standard Installation

```bash
sudo ./install.sh
```

This will:
1. Backup all system configurations
2. Apply PowerVigil™ settings
3. Install systemd services
4. Configure boot parameters
5. Set up the watchdog
6. Prompt for system reboot

### Custom Installation

For selective component installation:

```bash
# Configure without watchdog
sudo ./bin/powervigil-config --no-watchdog

# Verify specific components
sudo ./bin/powervigil-verify --component cpu
sudo ./bin/powervigil-verify --component display
```

## ✅ Verification

After installation and reboot:

```bash
# Run comprehensive verification
sudo ./bin/powervigil-verify

# Check service status
systemctl status powervigil.service
systemctl status powervigil-watchdog.service

# Monitor logs
journalctl -u powervigil-watchdog -f
```

### Expected Output

```
=== PowerVigil™ Status Verification ===

✓ Systemd targets masked
✓ CPU in performance mode (8/8 cores)
✓ Console blanking disabled
✓ DPMS disabled in X11
✓ USB autosuspend disabled
✓ Watchdog service active
✓ All systems optimal

PowerVigil™ Status: FULLY OPERATIONAL
```

## 🔄 Recovery Options

If display becomes unresponsive (rare with PowerVigil™):

### Automatic Recovery
The watchdog service automatically detects and resolves issues within 3 minutes.

### Manual Recovery (via SSH)
```bash
# Quick recovery
sudo powervigil-recover

# Force display wake
DISPLAY=:0 xset dpms force on

# Restart display manager
sudo systemctl restart gdm3  # or lightdm/sddm
```

## 📊 Monitoring

### Real-time Monitoring
```bash
# Watch PowerVigil™ activity
sudo powervigil-monitor

# View watchdog logs
tail -f /var/log/powervigil/watchdog.log

# System-wide power events
journalctl -f | grep -i "power\|suspend\|dpms"
```

### Performance Metrics
```bash
# CPU frequency verification
watch -n 1 'grep MHz /proc/cpuinfo'

# GPU status (NVIDIA)
nvidia-smi -l 1

# Temperature monitoring
watch -n 1 sensors
```

## 🛠️ Troubleshooting

See [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) for detailed troubleshooting guide.

### Common Issues

| Problem | Solution |
|---------|----------|
| Display still blanks | Run `sudo powervigil-verify` and address any ✗ items |
| CPU not in performance mode | Check BIOS for power management settings |
| Watchdog not starting | Ensure graphical.target is reached |
| GPU throttling | Check cooling, may need thermal solution |

## 🔄 Updates

```bash
# Update PowerVigil™
cd /path/to/powervigil
git pull
sudo ./install.sh --upgrade
```

## 🗑️ Uninstallation

```bash
# Complete removal and restoration
sudo ./uninstall.sh

# This will:
# - Restore all backed up configurations
# - Remove PowerVigil™ services
# - Reset power management to defaults
```

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

## 🏆 Use Cases

PowerVigil™ is perfect for:

- 🎮 Gaming kiosks
- 📺 Digital signage
- 🏪 Retail displays
- 🏭 Industrial HMI systems
- 🎨 Interactive exhibitions
- 📊 Dashboard monitors
- 🏥 Medical displays
- 🎓 Educational kiosks

## 💬 Support

- **Issues**: [GitHub Issues](https://github.com/suparious/powervigil/issues)
- **Discussions**: [GitHub Discussions](https://github.com/suparious/powervigil/discussions)
- **Wiki**: [PowerVigil Wiki](https://github.com/suparious/powervigil/wiki)

## 🙏 Acknowledgments

- Developed for production kiosk environments
- Battle-tested on Debian 13 (Trixie)
- Inspired by the need for truly reliable always-on displays

## 📈 Roadmap

- [ ] v1.1 - Ubuntu/Mint support
- [ ] v1.2 - Web-based monitoring dashboard
- [ ] v1.3 - Remote management capabilities
- [ ] v2.0 - AI-powered predictive maintenance

---

<div align="center">

**PowerVigil™** - *Because downtime is not an option*

Copyright © 2025 | GPL v3 License

</div>
