# SCP Client for macOS

A modern, native macOS application for secure file transfer over SSH/SCP with an intuitive graphical interface.

## Features

✨ **Core Functionality**
- 🔐 SSH/SCP file transfer with password and private key authentication
- 📁 Remote file browser with directory navigation
- ⬆️ Upload files with drag & drop support
- ⬇️ Download files with progress tracking
- 🔄 Real-time transfer progress bars
- 📝 Built-in terminal for remote command execution
- 🛠️ File management (create/delete directories, change permissions)

🎨 **User Experience**
- Modern SwiftUI interface
- Native macOS integration
- Responsive and fast
- Dark mode support
- Intuitive connection management

🔒 **Security**
- Uses libssh2 for secure connections
- Supports both password and key-based authentication
- Automatic SSH key handling
- No stored credentials (except in Keychain)

## Requirements

- macOS 13.0 or later
- Swift 5.9+
- libssh2 (installed via Homebrew)

## Installation

### From Source

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/scp-client-macos.git
cd scp-client-macos
```

2. **Install dependencies**
```bash
brew install libssh2 cmake sshpass
```

3. **Build the application**
```bash
./build.sh
```

4. **Create the macOS app bundle**
```bash
./package-app.sh
```

5. **Launch the application**
```bash
open build/SCPClient.app
```

### From Release

Download the latest `.dmg` file from the [Releases](https://github.com/yourusername/scp-client-macos/releases) page and drag SCPClient to Applications.

## Usage

### Adding a Connection

1. Click **"Add Connection"**
2. Enter connection details:
   - **Name**: Connection identifier
   - **Host**: Server IP or hostname
   - **Port**: SSH port (default: 22)
   - **Username**: Remote user
   - **Auth Type**: Password or Private Key
3. Click **"Connect"**

### File Transfer

- **Upload**: Drag files from Finder to the app, or use the upload button
- **Download**: Select files and click download, or drag to Finder
- **Progress**: Real-time transfer progress with speed and ETA

### File Management

- **Create Folder**: Right-click → New Folder
- **Delete**: Select file/folder → Delete
- **Permissions**: Right-click → Properties
- **Navigate**: Double-click folders to open

### Terminal

- Enter SSH commands in the terminal tab
- View command output in real-time
- Supports all standard shell commands

## Architecture

```
SCPClient/
├── Sources/
│   ├── Views/              # SwiftUI views
│   ├── Services/           # Business logic & SSH bridge
│   ├── Models/             # Data models
│   └── App.swift           # Entry point
├── Services/
│   ├── SCPSession.cpp      # C++ SSH implementation
│   ├── SCPSessionBridge.h  # Objective-C bridge
│   └── SCPSessionBridge.mm # Bridge implementation
└── Assets/                 # App icons and resources
```

## Technology Stack

- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI
- **SSH Library**: libssh2
- **Build System**: Swift Package Manager (SPM)
- **C++ Bridge**: Objective-C++

## Development

### Project Structure

- `Package.swift` - Swift Package Manager configuration
- `build.sh` - Build script
- `package-app.sh` - macOS app bundler
- `CMakeLists.txt` - C++ build configuration

### Building for Development

```bash
# Clean build
rm -rf .build build
./build.sh

# Run tests
swift test

# Generate documentation
swift package generate-documentation
```

### Code Style

- Follow Swift API Design Guidelines
- Use meaningful variable names
- Add documentation comments for public APIs
- Keep functions focused and testable

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Guidelines

- Follow existing code style
- Add tests for new features
- Update documentation
- Keep commits atomic and descriptive

## Known Limitations

- Terminal execution is synchronous (blocking)
- Large file transfers may use significant memory
- No built-in file comparison tools
- No scheduled transfers

## Roadmap

- [ ] Asynchronous terminal execution
- [ ] File comparison and sync
- [ ] Scheduled transfers
- [ ] Connection profiles
- [ ] SSH key generation UI
- [ ] Multi-file operations
- [ ] Bandwidth throttling

## Troubleshooting

### Connection Issues

**"Connection refused"**
- Verify SSH server is running: `ssh-keyscan -p 22 host`
- Check firewall settings
- Ensure correct port number

**"Authentication failed"**
- Verify credentials
- Check key permissions: `chmod 600 ~/.ssh/id_rsa`
- Ensure key is added to `authorized_keys`

### Transfer Issues

**"Permission denied"**
- Check file permissions on remote server
- Verify user has write access to destination

**"Slow transfers"**
- Check network connection
- Monitor server CPU/disk usage
- Try smaller files first

## Security Considerations

- ⚠️ Passwords are not stored (use SSH keys when possible)
- ⚠️ SSH keys should have proper permissions (600)
- ⚠️ Use strong passphrases for encrypted keys
- ⚠️ Keep libssh2 updated for security patches

## License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file for details.

## Support

- 📖 [Documentation](docs/)
- 🐛 [Report Issues](https://github.com/yourusername/scp-client-macos/issues)
- 💬 [Discussions](https://github.com/yourusername/scp-client-macos/discussions)

## Credits

- Built with Swift and SwiftUI
- SSH functionality via libssh2
- Icons by [Your Name]

## Changelog

### Version 1.0.0 (2025-11-07)
- Initial release
- SSH/SCP file transfer
- Remote file browser
- Terminal integration
- Modern macOS UI

---

**Made with ❤️ for the macOS community**
