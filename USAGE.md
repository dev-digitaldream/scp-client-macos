# 📘 Usage Guide - SCP Client for macOS

Complete guide to using SCP Client for secure file transfers.

## 🚀 Getting Started

### First Launch

1. Open SCP Client from Applications or using `open build/SCPClient.app`
2. Click **"New Connection"** to create your first connection
3. Fill in the connection details:
   - **Name**: A friendly name (e.g., "My Server")
   - **Host**: Server IP or hostname
   - **Port**: SSH port (default: 22)
   - **Username**: SSH username
   - **Auth Type**: Password or SSH Key

### Creating a Connection

#### Option 1: Password Authentication

1. Click **"New Connection"**
2. Enter connection details
3. Select **"Password"** as auth type
4. Enter your SSH password
5. Click **"Connect"**

#### Option 2: SSH Key Authentication

1. Click **"New Connection"**
2. Enter connection details
3. Select **"SSH Key"** as auth type
4. Click **"Select Key"** and choose your private key file
   - Common locations: `~/.ssh/id_rsa`, `~/.ssh/id_ed25519`
5. (Optional) Enter passphrase if key is encrypted
6. Click **"Connect"**

### Saving Connections

When creating a connection:
- Check **"Remember this connection"** to save it
- Saved connections appear in the sidebar
- Click any saved connection to connect instantly

## 📁 File Operations

### Uploading Files

#### Method 1: Drag & Drop
1. Open local folder in Finder
2. Drag files directly into SCP Client window
3. Files upload automatically

#### Method 2: From Local Files
1. Click **"Upload"** button (if available)
2. Select files from disk
3. Choose destination directory
4. Files upload with progress

### Downloading Files

1. Right-click the file in the file list
2. Select **"Download"**
3. Choose local destination folder
4. File downloads with progress bar

### Creating Folders

1. Click **"New Folder"** button (folder icon with +)
2. Enter folder name
3. Click **"Create"**

### Deleting Files/Folders

1. Right-click the item
2. Select **"Delete"**
3. Confirm deletion
4. Item is removed from server

### Navigation

- **Back Button**: Go up one directory level
- **Path Bar**: Shows current directory (clickable)
- **Double-click**: Enter a folder
- **Refresh Button**: Reload directory contents

## 📊 Transfer Management

### Monitoring Transfers

The transfer panel shows:
- **File name** being transferred
- **Progress bar** with percentage
- **Speed** (MB/s)
- **Time remaining**
- **Cancel button** to stop transfer

### Multiple Simultaneous Transfers

- Upload/download multiple files at once
- Each transfer shows separately in transfer panel
- Cancel individual transfers without affecting others

## 🔐 Security Features

### Password Management

- Passwords are **NOT stored** on disk
- Use "Remember password" to store securely in macOS Keychain
- Each session requires authentication (unless saved)

### SSH Keys

- Private keys are never uploaded to the server
- Support for:
  - RSA keys (2048, 4096 bits)
  - ECDSA keys
  - Ed25519 keys
- Key file must have proper permissions:
  ```bash
  chmod 600 ~/.ssh/id_rsa
  ```

### Connection Security

- All connections use SSH (encrypted)
- Host key verification enabled
- Support for jump hosts (SSH proxies)

## ⌨️ Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `⌘N` | New Connection |
| `⌘W` | Close Window |
| `⌘Q` | Quit Application |
| `⌘R` | Refresh Directory |
| `Delete` | Delete Selected File |
| `Enter/Return` | Open Selected Folder |
| `Escape` | Deselect/Close Dialog |

## 🔍 Tips & Tricks

### Efficient Workflows

1. **Save frequently used servers** in sidebar
2. **Use keyboard shortcuts** for faster navigation
3. **Drag multiple files** for batch uploads
4. **Sort columns** by clicking headers (name, size, date)

### Common Tasks

#### Copy File to Local
1. Right-click remote file
2. Click "Download"
3. Choose destination
4. Wait for completion

#### Upload Modified File
1. Drag updated file from Finder
2. Confirm overwrite (if exists)
3. File transfers instantly

#### Browse Server Directories
1. Connect to server
2. Double-click folders to navigate
3. Use back button to go up
4. Current path shows in header

### Performance Tips

- **Large files**: Check network speed first
  ```bash
  iperf3 -c your-server.com
  ```
- **Many files**: Use compound operations when possible
- **Slow connection**: Consider compressing before transfer

## 🐛 Troubleshooting

### Can't Connect

**Issue**: "Connection refused"

```bash
# Test SSH connection manually
ssh -p 22 user@hostname

# Check if SSH server is running
ssh -p 22 hostname "echo test"
```

**Solution**:
- Verify hostname/IP is correct
- Check SSH port (usually 22)
- Ensure SSH service is running on server
- Check firewall rules

### Permission Denied

**Issue**: Can't download/delete files

```bash
# Check file permissions on server
ls -l filename
```

**Solution**:
- Contact server admin for permission changes
- Use different user account with more permissions
- Copy file to writable directory first

### Key Authentication Fails

**Issue**: "Permission denied (publickey)"

```bash
# Check key permissions
ls -la ~/.ssh/id_rsa

# Should show: -rw------- (600)
# If not, fix with:
chmod 600 ~/.ssh/id_rsa
```

**Solution**:
- Verify key file path is correct
- Check key permissions (must be 600)
- Confirm public key is on server in `~/.ssh/authorized_keys`

### Transfers Fail Midway

**Issue**: "Connection lost" during transfer

**Solution**:
- Check network stability
- Try with smaller files first
- Increase timeout settings
- Use compression for large files

### App Crashes

**Solution**:
1. Restart the app
2. Try a fresh connection
3. Check Console.app for error messages
4. Report issue on GitHub with error details

## 📞 Getting Support

- **Documentation**: See [README.md](README.md)
- **Installation Help**: See [INSTALL.md](INSTALL.md)
- **Bug Reports**: [GitHub Issues](https://github.com/dev-digitaldream/scp-client-macos/issues)
- **Questions**: [GitHub Discussions](https://github.com/dev-digitaldream/scp-client-macos/discussions)

## 🔄 Advanced Features

### SSH Key Management

Best practices for SSH keys:

```bash
# Generate new SSH key
ssh-keygen -t ed25519 -C "your_email@example.com"

# Set proper permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub

# Add to server
ssh-copy-id -i ~/.ssh/id_ed25519 user@hostname
```

### Connection Profiles

Save different connections for:
- Production servers
- Development servers
- Backup systems
- Multiple user accounts

Each profile can have different:
- Authentication method
- Default directory
- Connection name
- Saved password

---

**Last Updated:** November 2024

**Version:** 1.0.0
