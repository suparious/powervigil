# PowerVigil™ Changelog

All notable changes to PowerVigil™ will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] - 2025-01-22

### Added
- New `powervigil-disable-conflicts` utility to disable conflicting power management services
- Automatic detection and disabling of conflicting services in main configuration
- Better detection of conflicting services in verification script
- Support for disabling power-profiles-daemon, upower, thermald, tlp, laptop-mode, and auto-cpufreq

### Fixed
- Debian package build process now preserves maintainer scripts
- Added `.gitignore` entries for Debian build artifacts
- Build script now backs up and restores maintainer scripts automatically

### Changed
- Configuration script now includes Layer 12b for conflicting service management
- Verification script provides clearer guidance on fixing conflicts
- Updated documentation for build process

## [1.0.0] - 2025-01-22

### Added
- Initial release of PowerVigil™ Kiosk Performance & Recovery Framework
- 13-Layer Protection Matrix implementation
- Main configuration script (`powervigil-config`)
- Verification utility (`powervigil-verify`)
- Watchdog daemon with auto-recovery (`powervigil-watchdog`)
- Systemd service definitions
- One-click installation script
- Clean uninstallation script
- Recovery tools for manual intervention
- Real-time monitoring capabilities
- Comprehensive documentation

### Features
- Complete power management disabling across all system levels
- CPU and GPU performance mode enforcement
- Display server DPMS elimination
- USB autosuspend prevention
- Network power saving deactivation
- Console blanking removal
- ACPI event disabling
- Desktop environment idle action prevention
- Automatic display recovery within 3 minutes
- Configuration backup and restore functionality

### Tested
- Debian 13 (Trixie) - Full compatibility
- X11 and Wayland display servers
- GNOME, KDE, XFCE desktop environments
- NVIDIA and AMD GPU support

### Security
- GPL v3 licensed
- No external dependencies
- Root privilege requirements clearly documented
- Backup creation before system modifications

### Known Issues
- None in initial release

---

[1.0.0]: https://github.com/suparious/powervigil/releases/tag/v1.0.0
