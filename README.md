# SSH Agent Setup Utility

A robust Bash utility script that automatically sets up SSH agent and loads all SSH private keys from your `~/.ssh` directory. Perfect for development environments and automated workflows.

## Features

- **Automatic SSH Agent Setup**: Starts `ssh-agent` if not already running
- **Bulk Key Loading**: Discovers and loads all SSH private keys from `~/.ssh`
- **Smart Filtering**: Automatically excludes public keys (`.pub`) and configuration files
- **Duplicate Prevention**: Prevents loading the same key multiple times
- **Silent Mode**: Optional mute flag for script automation

## Quick Start

```bash
# Download the script
wget https://raw.githubusercontent.com/rikkarth/ssh-agent-set-me-up/refs/heads/master/src/ssh-agent-setup.sh

source ssh-agent-setup.sh
```

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

The SSH setup process follows these steps:

1. **SSH Agent Check**: Verifies if `ssh-agent` is running via `$SSH_AUTH_SOCK`
2. **Agent Startup**: Starts `ssh-agent` if not already running
3. **Key Discovery**: Scans `~/.ssh/` directory for potential private key files
4. **Smart Filtering**: Excludes:
   - Public keys (`.pub` files)
   - Configuration files (`config`, `known_hosts`, `authorized_keys`, etc.)
   - Already processed keys (prevents duplicates)
5. **Key Loading**: Attempts to load each discovered private key
6. **Setup Complete**: Reports success and loaded key count

## File Exclusions

The script automatically excludes these common SSH files:

- `known_hosts` and `known_hosts.old`
- `config`
- `authorized_keys`
- `environment`
- Any file with `.pub` extension

## Examples

### Standard Setup Workflow

```bash
$ source src/ssh-agent-setup.sh
Starting ssh-agent...
ssh-agent started successfully
Loading SSH keys from /home/user/.ssh...
✓ Added SSH key: id_ed25519
✓ Added SSH key: id_rsa
✓ Added SSH key: github_deploy_key
Successfully loaded 3 SSH key(s)
SSH agent setup complete
```

### Silent Mode Setup

```bash
$ source src/ssh-agent-setup.sh --mute
# No output, but keys are loaded silently
```

### Integration in Shell Profile

Add to your `~/.bashrc`, `~/.zshrc`, or shell profile:

```bash
# Auto-setup SSH keys on shell startup
if [ -f ~/ssh-agent-setup.sh ]; then
    source ~/ssh-agent-setup.sh --mute
fi
```

### Development Environment Setup

```bash
# In your project's setup script
echo "Setting up SSH environment..."
source path/to/ssh-agent-setup.sh --mute
echo "SSH setup complete, ready for git operations"
```

## Installation

### Manual Installation

### Git Clone

```bash
git clone git@github.com:rikkarth/ssh-agent-set-me-up.git
cd ssh-agent-set-me-up
source src/ssh-agent-setup.sh
```

## Requirements

- **Bash**: Version 4.0 or higher (for associative arrays)
- **OpenSSH**: Standard `ssh-agent` and `ssh-add` utilities
- **Permissions**: Read access to `~/.ssh` directory
- **SSH Keys**: At least one SSH private key in `~/.ssh`

## Security Considerations

- **Private Key Safety**: Only processes files that appear to be private keys
- **No Hardcoded Paths**: Uses standard SSH directory locations
- **Error Suppression**: Prevents sensitive key information from appearing in error messages
- **Permission Respect**: Respects file system permissions
- **No Global Pollution**: Doesn't leave variables in your shell environment

## Troubleshooting

### No Keys Added

If no keys are added, check:

1. **SSH Directory**: Ensure `~/.ssh` exists and contains private keys
   ```bash
   ls -la ~/.ssh/
   ```

2. **Permissions**: Verify read access to key files
   ```bash
   chmod 700 ~/.ssh
   chmod 600 ~/.ssh/id_*
   ```

3. **Key Format**: Ensure keys are in standard OpenSSH format
4. **Agent Status**: Check if keys are already loaded
   ```bash
   ssh-add -l
   ```

### Permission Denied

```bash
# Fix SSH directory permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_*

# Ensure you own the files
chown -R $USER:$USER ~/.ssh/
```

### Script Not Found

```bash
# Make script executable
chmod +x ssh-agent-setup.sh

# Check file exists
ls -la ssh-agent-setup.sh
```

### Agent Already Running

If you see "ssh-agent already running", this is normal behavior. The script detected an existing agent and used it.

## Use Cases

- **Development Setup**: Automatically load keys when starting development work
- **CI/CD Pipelines**: Setup SSH access in automated environments
- **Remote Server Setup**: Bootstrap SSH access on new servers
- **Docker Containers**: Setup SSH access in containerized environments
- **Shell Profiles**: Automatic SSH setup on login

## Contributing

When contributing to this project:

1. Fork the repository
2. Create a feature branch
3. Follow existing code style and documentation standards
4. Update documentation for any changes
5. Ensure backward compatibility
6. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

**Ricardo Mendes** - ricardo.mendes@streambit.dev
