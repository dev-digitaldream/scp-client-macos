# Contributing to SCP Client for macOS

Thank you for your interest in contributing! This document provides guidelines and instructions for contributing.

## Code of Conduct

Be respectful, inclusive, and constructive in all interactions.

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally
3. **Create a feature branch** from `main`
4. **Make your changes**
5. **Test thoroughly**
6. **Submit a Pull Request**

## Development Setup

```bash
# Clone and setup
git clone https://github.com/yourusername/scp-client-macos.git
cd scp-client-macos

# Install dependencies
brew install libssh2 cmake sshpass

# Build
./build.sh

# Run
open build/SCPClient.app
```

## Coding Standards

### Swift Code

- Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use meaningful variable and function names
- Add documentation comments for public APIs
- Keep functions focused and testable
- Use `// MARK:` for code organization

Example:
```swift
/// Connects to a remote SSH server
/// - Parameters:
///   - connection: The connection configuration
///   - password: The SSH password
/// - Throws: ConnectionError if connection fails
func connect(to connection: Connection, password: String) async throws {
    // Implementation
}
```

### C++ Code

- Follow Google C++ Style Guide
- Use meaningful variable names
- Add comments for complex logic
- Keep functions small and focused

### Objective-C Bridge

- Keep bridge methods simple
- Avoid complex logic in bridge code
- Document parameter types clearly

## Commit Messages

Use clear, descriptive commit messages:

```
Add SSH key validation feature

- Validate SSH keys before connection
- Show error dialog for invalid keys
- Add unit tests for validation
```

**Format:**
- First line: Brief summary (50 chars max)
- Blank line
- Detailed explanation (if needed)
- Reference issues: `Fixes #123`

## Pull Request Process

1. **Update documentation** if needed
2. **Add tests** for new features
3. **Test on macOS 13+**
4. **Ensure no breaking changes**
5. **Write clear PR description**

### PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Performance improvement

## Testing
- [ ] Unit tests added
- [ ] Manual testing done
- [ ] Tested on macOS 13+

## Checklist
- [ ] Code follows style guidelines
- [ ] Documentation updated
- [ ] No new warnings introduced
```

## Testing

### Unit Tests

```bash
swift test
```

### Manual Testing

1. Test SSH connection with password
2. Test SSH connection with key
3. Test file upload/download
4. Test terminal commands
5. Test error handling

### Test Coverage

Aim for >80% code coverage on new code.

## Documentation

- Update README.md for user-facing changes
- Add inline comments for complex logic
- Update CHANGELOG.md
- Document new APIs in code

## Reporting Issues

### Bug Reports

Include:
- macOS version
- Steps to reproduce
- Expected behavior
- Actual behavior
- Screenshots if applicable

### Feature Requests

Include:
- Use case
- Proposed solution
- Alternative approaches
- Examples

## Areas for Contribution

### High Priority

- [ ] Performance optimization
- [ ] Error handling improvements
- [ ] Documentation
- [ ] Bug fixes

### Medium Priority

- [ ] UI/UX improvements
- [ ] New features
- [ ] Code refactoring
- [ ] Test coverage

### Low Priority

- [ ] Code style improvements
- [ ] Minor documentation updates

## Questions?

- Open an issue with `[QUESTION]` tag
- Check existing issues first
- Be specific and provide context

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing! 🎉
