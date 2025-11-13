# 📖 Installation Guide - SCP Client for macOS

Complete step-by-step guide to install and build SCP Client for macOS.

## 🔍 System Requirements

- **macOS 13.0+** (Ventura or newer)
- **Xcode 15.0+** with Command Line Tools
- **Homebrew** (macOS package manager)
- **Intel or Apple Silicon** (arm64) Mac

### Check Your System

```bash
# Check macOS version
sw_vers -productVersion

# Check if Xcode Command Line Tools are installed
xcode-select -p

# Check if Homebrew is installed
brew --version
```

## 📥 Installation Steps

### 1. Install Xcode Command Line Tools

If not already installed:

```bash
xcode-select --install
```

Follow the prompts to complete the installation.

### 2. Install Homebrew

If not already installed:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 3. Install Dependencies

SCP Client requires `libssh2` and `cmake`:

```bash
brew install libssh2 cmake pkg-config
```

Verify installation:

```bash
brew list libssh2
pkg-config --version
cmake --version
```

### 4. Clone the Repository

```bash
git clone https://github.com/dev-digitaldream/scp-client-macos.git
cd scp-client-macos
```

### 5. Build the Application

#### Option A: Build and Package (Recommended)

```bash
# Run the build script
./build.sh

# Package as macOS app
./package-app.sh

# Launch the app
open build/SCPClient.app
```

#### Option B: Manual Build

```bash
# Build C++ core
mkdir -p build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_DEPLOYMENT_TARGET=13.0
cmake --build . --config Release
cd ..

# Build Swift app
swift build -c release

# Run from CLI
.build/release/SCPClient

# Or package it
./package-app.sh
open build/SCPClient.app
```

#### Option C: Debug Build

```bash
swift build
.build/debug/SCPClient
```

## 🚀 Launch the Application

### From CLI
```bash
.build/release/SCPClient
```

### From Finder
```bash
open build/SCPClient.app
```

### Install in Applications Folder
```bash
cp -r build/SCPClient.app /Applications/
```

Then launch from Launchpad or Spotlight (⌘ Space, type "SCP Client")

## 📦 Create DMG Installer

```bash
cd build
hdiutil create -volname "SCP-Client-macOS" -srcfolder "SCPClient.app" -ov -format UDZO "SCP-Client-macOS.dmg"
```

This creates `SCP-Client-macOS.dmg` that can be distributed.

## 🔧 Troubleshooting

### "Command not found: cmake"

```bash
# Install cmake
brew install cmake

# Or add to PATH
export PATH="/opt/homebrew/bin:$PATH"
```

### "Could not find libssh2"

```bash
# Reinstall libssh2
brew reinstall libssh2

# Verify
pkg-config --cflags --libs libssh2
```

### Build fails with C++ errors

```bash
# Clean and rebuild
rm -rf build .build
./build.sh
```

### "No such file or directory" for libssh2

**For Intel Macs:**
```bash
brew install libssh2
# Check installation path
ls /usr/local/opt/libssh2/lib
```

**For Apple Silicon Macs:**
```bash
brew install libssh2
# Check installation path
ls /opt/homebrew/opt/libssh2/lib
```

### Swift compilation warnings about Sendable

These are non-critical warnings. The app will build and run fine.

```
warning: capture of 'self' with non-Sendable type 'ConnectionService'
```

These are expected in the current version and don't affect functionality.

## 📝 Development Build

For development with hot-reload:

```bash
# Terminal 1: Watch and rebuild
while true; do
  swift build
  sleep 1
done

# Terminal 2: Run the app
.build/debug/SCPClient
```

## 🧪 Running Tests

```bash
swift test
```

## 📁 Build Output

After building, you'll have:

```
build/
├── SCPClient.app/           # Packaged application
├── SCP-Client-macOS.dmg     # DMG installer (if created)
└── CMakeFiles/              # C++ build artifacts

.build/
├── release/
│   └── SCPClient            # Release executable
└── debug/
    └── SCPClient            # Debug executable
```

## 🆘 Getting Help

If you encounter issues:

1. Check this INSTALL.md file
2. Review the [README.md](README.md)
3. Check [GitHub Issues](https://github.com/dev-digitaldream/scp-client-macos/issues)
4. See [USAGE.md](USAGE.md) for usage instructions

## ✅ Verification

To verify your installation:

```bash
# Check the app works
open build/SCPClient.app

# Try connecting to a test server
# (use your own SSH server for testing)
```

The app should launch with a connection dialog. You can now create new connections!

---

**Last Updated:** November 2024
