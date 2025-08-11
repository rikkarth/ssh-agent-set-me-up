# SSH Agent Manager

A robust Bash utility script that automatically starts `ssh-agent` and loads all SSH private keys from your `~/.ssh` directory.

## Features

- **Automatic SSH Agent Management**: Starts `ssh-agent` if not already running
- **Bulk Key Loading**: Discovers and loads all SSH private keys from `~/.ssh`
- **Smart Filtering**: Automatically excludes public keys (`.pub`) and configuration files
- **Duplicate Prevention**: Prevents loading the same key multiple times
- **Silent Mode**: Optional mute flag for script automation
- **Error Handling**: Robust error handling with proper exit codes
- **Best Practices**: Follows shell scripting best practices with comprehensive documentation

## Usage

### Basic Usage

```bash
# Source the script to load keys with output
source ssh-agent-setup.sh

# Or execute directly
./ssh-agent-setup.sh
```

### Silent Mode

```bash
# Load keys without output messages
source ssh-agent-setup.sh --mute
source ssh-agent-setup.sh -m
```

### Help and Version

```bash
# Display help
./ssh-agent-setup.sh --help

# Display version
./ssh-agent-setup.sh --version
```

## Command Line Options

| Option | Description |
|--------|-------------|
| `-m, --mute` | Suppress non-error output messages |
| `-h, --help` | Display help message and usage information |
| `-v, --version` | Display version information |

## How It Works

1. **SSH Agent Check**: Verifies if `ssh-agent` is running via `$SSH_AUTH_SOCK`
2. **Agent Startup**: Starts `ssh-agent` if not already running
3. **Key Discovery**: Scans `~/.ssh/` directory for potential private key files
4. **Smart Filtering**: Excludes:
   - Public keys (`.pub` files)
   - Configuration files (`config`, `known_hosts`, `authorized_keys`, etc.)
   - Already processed keys (prevents duplicates)
5. **Key Loading**: Attempts to load each discovered private key
6. **Reporting**: Provides feedback on successfully loaded keys

## File Exclusions

The script automatically excludes these common SSH files:

- `known_hosts` and `known_hosts.old`
- `config`
- `authorized_keys`
- `environment`
- Any file with `.pub` extension

## Examples

### Standard Workflow

```bash
$ source ssh-agent-setup.sh
Starting ssh-agent...
ssh-agent started successfully
Loading SSH keys from /home/user/.ssh...
✓ Added SSH key: id_ed25519
✓ Added SSH key: id_rsa
✓ Added SSH key: github_key
Successfully loaded 3 SSH key(s)
SSH agent setup complete
```

### Silent Mode

```bash
$ source ssh-agent-setup.sh --mute
# No output, but keys are loaded
```

### Integration in Shell Profile

Add to your `~/.bashrc` or `~/.zshrc`:

```bash
# Auto-load SSH keys on shell startup
if [ -f ~/path/to/ssh-agent-setup.sh ]; then
    source ~/path/to/ssh-agent-setup.sh --mute
fi
```

## Requirements

- **Bash**: Version 4.0 or higher (for associative arrays)
- **OpenSSH**: Standard `ssh-agent` and `ssh-add` utilities
- **Permissions**: Read access to `~/.ssh` directory

## Error Handling

The script includes comprehensive error handling:

- **Missing SSH Directory**: Reports error if `~/.ssh` doesn't exist
- **Invalid Arguments**: Shows usage help for unknown options
- **Key Loading Failures**: Silently skips invalid key files
- **Permission Issues**: Handles permission errors gracefully

## Security Considerations

- **Private Key Safety**: Only processes files that appear to be private keys
- **No Hardcoded Paths**: Uses standard SSH directory locations
- **Error Suppression**: Prevents sensitive key information from appearing in error messages
- **Permission Respect**: Respects file system permissions

## Troubleshooting

### No Keys Added

If no keys are added, check:

1. **SSH Directory**: Ensure `~/.ssh` exists and contains private keys
2. **Permissions**: Verify read access to key files
3. **Key Format**: Ensure keys are in standard OpenSSH format
4. **Agent Status**: Check if keys are already loaded with `ssh-add -l`

### Permission Denied

```bash
# Fix SSH directory permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_*
```

### Script Not Found

```bash
# Make script executable
chmod +x ssh-agent-setup.sh
```

## Contributing

When contributing to this script:

1. Follow existing code style and documentation standards
2. Add tests for new functionality
3. Update documentation for any changes
4. Ensure backward compatibility

## License

This script is provided as-is for personal and professional use. Modify and distribute freely while maintaining attribution.

## Version History

- **v1.0**: Initial release with comprehensive key loading and documentation
