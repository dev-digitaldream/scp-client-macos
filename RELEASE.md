# Release Instructions for SCP Client for macOS

## Pre-Release Checklist

- [ ] All tests passing
- [ ] No compiler warnings
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] Version bumped in Package.swift
- [ ] Code reviewed
- [ ] Security audit completed

## Building Release

```bash
# Clean build
rm -rf .build build

# Build for release
./build.sh

# Create app bundle
./package-app.sh

# Create DMG
hdiutil create -volname "SCPClient" -srcfolder "build/SCPClient.app" -ov -format UDZO "build/SCPClient.dmg"
```

## Signing (Optional but Recommended)

```bash
# Sign the app
codesign --deep --force --verify --verbose --sign "Developer ID Application" "build/SCPClient.app"

# Verify signature
codesign -v "build/SCPClient.app"

# Notarize (if using Developer ID)
xcrun altool --notarize-app --file "build/SCPClient.dmg" --primary-bundle-id "com.scpclient.app" --username "your-apple-id" --password "@keychain:Developer-ID-Notarization"
```

## Publishing to GitHub

1. **Create a release tag**
```bash
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

2. **Create GitHub Release**
   - Go to Releases page
   - Click "Draft a new release"
   - Select the tag
   - Add release notes
   - Upload SCPClient.dmg
   - Publish

## Release Notes Template

```markdown
# SCP Client for macOS v1.0.0

## What's New

### Features
- Feature 1
- Feature 2

### Improvements
- Improvement 1
- Improvement 2

### Bug Fixes
- Bug fix 1
- Bug fix 2

### Known Issues
- Known issue 1

## Installation

Download SCPClient.dmg and drag to Applications folder.

## Requirements

- macOS 13.0 or later

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for full history.
```

## Distribution Channels

### 1. GitHub Releases
- Primary distribution method
- Automatic updates via Sparkle (optional)

### 2. Homebrew (Optional)
```bash
# Create homebrew formula
# Submit to homebrew-cask
```

### 3. App Store (Optional)
- Requires Apple Developer account
- More complex review process
- Better discoverability

### 4. Direct Website
- Host on project website
- Provide download links

## Version Numbering

Use Semantic Versioning: MAJOR.MINOR.PATCH

- MAJOR: Breaking changes
- MINOR: New features (backward compatible)
- PATCH: Bug fixes

Example: 1.2.3

## Updating Version

1. **Update Package.swift**
```swift
let package = Package(
    name: "SCPClient",
    // ...
)
```

2. **Update Info.plist** (in package-app.sh)
```xml
<key>CFBundleShortVersionString</key>
<string>1.0.0</string>
<key>CFBundleVersion</key>
<string>1</string>
```

3. **Update CHANGELOG.md**

## Post-Release

1. **Announce release**
   - Twitter/X
   - GitHub Discussions
   - Email newsletter (if applicable)

2. **Monitor feedback**
   - Check issues
   - Respond to bug reports
   - Plan next release

3. **Plan next version**
   - Review roadmap
   - Prioritize features
   - Assign to milestone

## Rollback Procedure

If critical issues found:

1. **Create hotfix branch**
```bash
git checkout -b hotfix/v1.0.1
```

2. **Fix issues**

3. **Test thoroughly**

4. **Release v1.0.1**

5. **Delete problematic release**

## Continuous Integration

Consider setting up CI/CD:

- GitHub Actions for automated builds
- Automated testing on each commit
- Automatic DMG creation
- Automatic release drafts

## Security

- Keep dependencies updated
- Review security advisories
- Sign releases with Developer ID
- Notarize for Gatekeeper

## Support

- Monitor GitHub Issues
- Respond to bug reports
- Provide documentation
- Help community members

---

**Release Manager**: [Your Name]
**Last Updated**: 2025-11-07
