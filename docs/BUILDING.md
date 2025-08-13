# Building PowerVigil™ Debian Package

## Prerequisites

Before building the PowerVigil Debian package, you need to install the build dependencies:

```bash
sudo apt-get update
sudo apt-get install -y dpkg-dev debhelper devscripts build-essential
```

## Build Process

Once dependencies are installed:

```bash
# Make the build script executable (if not already)
chmod +x build-deb.sh

# Build the package
./build-deb.sh
```

The package will be created in the parent directory as:
```
../powervigil_1.0.0-1_all.deb
```

## Troubleshooting

### Missing Dependencies
If you see "Missing build dependencies", install them with:
```bash
sudo apt-get update && sudo apt-get install -y dpkg-dev debhelper devscripts build-essential
```

### Permission Errors
Ensure all scripts are executable:
```bash
chmod +x build-deb.sh
chmod +x debian/rules
chmod +x debian/postinst debian/prerm debian/postrm
chmod +x bin/*
```

### Build Errors
If the build fails, check:
1. All required files are present in `debian/` directory
2. No `debian/compat` file exists (removed to avoid conflicts)
3. Version in `debian/changelog` matches expected format

### Clean Build
To start fresh:
```bash
# Clean all build artifacts
rm -rf debian/powervigil
rm -f ../powervigil_*.deb
rm -f ../powervigil_*.dsc
rm -f ../powervigil_*.tar.*
rm -f ../powervigil_*.changes
rm -f ../powervigil_*.buildinfo

# Then rebuild
./build-deb.sh
```

## Testing the Package

After building, test the package locally:

```bash
# Install the package
sudo dpkg -i ../powervigil_1.0.0-1_all.deb

# If there are dependency issues, fix them with:
sudo apt-get install -f

# Verify installation
dpkg -l powervigil
powervigil-verify

# Check installed files
dpkg -L powervigil
```

## Building for Different Architectures

PowerVigil is architecture-independent (shell scripts), so the package is built as `_all.deb` which works on any architecture.

## Signing Packages

For production deployment, sign your packages:

```bash
# Sign with your GPG key
dpkg-sig --sign builder ../powervigil_*.deb
```

## Version Updates

To build a new version:

1. Update the version in `debian/changelog`:
```bash
dch -v 1.0.1-1 "Description of changes"
```

2. Update VERSION file:
```bash
echo "1.0.1" > VERSION
```

3. Rebuild the package:
```bash
./build-deb.sh
```

## Notes

- The package is built without signatures (`-us -uc`) for local testing
- For production repositories, consider signing packages and repository metadata
- The package automatically configures PowerVigil on installation
- A reboot is required after installation to activate all features
